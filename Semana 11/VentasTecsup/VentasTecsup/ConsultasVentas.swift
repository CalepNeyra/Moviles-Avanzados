import CoreData
import Foundation

struct IndicadoresVentas {
    let totalHoy: Decimal
    let cantidadHoy: Int
    let totalMes: Decimal
    let cantidadMes: Int
}

struct TotalDiario {
    let fecha: Date
    let total: Decimal
}

struct TotalVendedor {
    let nombre: String
    let total: Decimal
}

struct ResumenSupervisor {
    let totalHoy: Decimal
    let variacionRespectoAyer: Decimal?
    let igvMes: Decimal
    let ultimosSieteDias: [TotalDiario]
    let rankingVendedores: [TotalVendedor]
    let stockBajo: [Producto]
}

extension RepositorioVentas {
    func misVentas(periodo: PeriodoVentas = .todas, cliente: String = "", fecha: Date = Date(), calendario: Calendar = .current) throws -> [Venta] {
        let vendedor = try exigirSesion(.vendedor)
        return try listarVentas(vendedor: vendedor, periodo: periodo, cliente: cliente, fecha: fecha, calendario: calendario)
    }

    func ventasEquipo(periodo: PeriodoVentas = .todas, vendedor: Usuario? = nil, cliente: String = "", fecha: Date = Date(), calendario: Calendar = .current) throws -> [Venta] {
        _ = try exigirSesion(.supervisor)
        if let vendedor { try verificar(vendedor) }
        return try listarVentas(vendedor: vendedor, periodo: periodo, cliente: cliente, fecha: fecha, calendario: calendario)
    }

    func vendedores() throws -> [Usuario] {
        _ = try exigirSesion(.supervisor)
        return try consultar(Usuario.self, filtros: [
            NSPredicate(format: "rol == %@", Rol.vendedor.rawValue)
        ], orden: [NSSortDescriptor(key: "nombre", ascending: true)])
    }

    func indicadoresPersonales(fecha: Date = Date(), calendario: Calendar = .current) throws -> IndicadoresVentas {
        let vendedor = try exigirSesion(.vendedor)
        let filtro = NSPredicate(format: "vendedor == %@", argumentArray: [vendedor])
        let hoy = try vigentes(en: intervalo(.hoy, fecha: fecha, calendario: calendario), filtros: [filtro])
        let mes = try vigentes(en: intervalo(.mes, fecha: fecha, calendario: calendario), filtros: [filtro])
        return IndicadoresVentas(totalHoy: total(hoy), cantidadHoy: hoy.count, totalMes: total(mes), cantidadMes: mes.count)
    }

    func resumenSupervisor(fecha: Date = Date(), calendario: Calendar = .current) throws -> ResumenSupervisor {
        _ = try exigirSesion(.supervisor)
        let hoy = try intervalo(.hoy, fecha: fecha, calendario: calendario)
        let mes = try intervalo(.mes, fecha: fecha, calendario: calendario)
        guard let primerDia = calendario.date(byAdding: .day, value: -6, to: hoy.start),
              let ayer = calendario.date(byAdding: .day, value: -1, to: hoy.start) else {
            throw ErrorVentas.calendarioInvalido
        }

        let recientes = try vigentes(en: DateInterval(start: primerDia, end: hoy.end))
        let porDia = Dictionary(grouping: recientes) { calendario.startOfDay(for: $0.fecha) }
        let dias = try (0..<7).map { desplazamiento in
            guard let dia = calendario.date(byAdding: .day, value: desplazamiento, to: primerDia) else {
                throw ErrorVentas.calendarioInvalido
            }
            let inicio = calendario.startOfDay(for: dia)
            return TotalDiario(fecha: inicio, total: total(porDia[inicio] ?? []))
        }

        let ventasMes = try vigentes(en: mes)
        let ranking = Dictionary(grouping: ventasMes, by: { $0.vendedor.objectID }).values
            .compactMap { ventas -> TotalVendedor? in
                guard let vendedor = ventas.first?.vendedor else { return nil }
                return TotalVendedor(nombre: vendedor.nombre, total: total(ventas))
            }
            .sorted {
                if $0.total == $1.total { return $0.nombre.localizedStandardCompare($1.nombre) == .orderedAscending }
                return $0.total > $1.total
            }

        let totalHoy = total(porDia[hoy.start] ?? [])
        let totalAyer = total(porDia[calendario.startOfDay(for: ayer)] ?? [])
        let variacion = totalAyer == 0 ? nil : ReglasVentas.redondear((totalHoy - totalAyer) * 100 / totalAyer)
        let stockBajo = try consultar(Producto.self, filtros: [NSPredicate(format: "stock <= 5")], orden: [
            NSSortDescriptor(key: "stock", ascending: true),
            NSSortDescriptor(key: "nombre", ascending: true)
        ])

        return ResumenSupervisor(
            totalHoy: totalHoy,
            variacionRespectoAyer: variacion,
            igvMes: ventasMes.reduce(Decimal.zero) { $0 + importe($1.igv) },
            ultimosSieteDias: dias,
            rankingVendedores: ranking,
            stockBajo: stockBajo
        )
    }

    private func listarVentas(vendedor: Usuario?, periodo: PeriodoVentas, cliente: String, fecha: Date, calendario: Calendar) throws -> [Venta] {
        var filtros: [NSPredicate] = []
        if let vendedor { filtros.append(NSPredicate(format: "vendedor == %@", argumentArray: [vendedor])) }
        if periodo != .todas {
            filtros.append(filtroFechas(try intervalo(periodo, fecha: fecha, calendario: calendario)))
        }
        let cliente = limpiar(cliente)
        if !cliente.isEmpty {
            filtros.append(NSPredicate(format: "cliente.nombre CONTAINS[cd] %@", cliente))
        }
        return try consultar(Venta.self, filtros: filtros, orden: [NSSortDescriptor(key: "fecha", ascending: false)])
    }

    private func vigentes(en intervalo: DateInterval, filtros: [NSPredicate] = []) throws -> [Venta] {
        try consultar(Venta.self, filtros: filtros + [filtroFechas(intervalo), NSPredicate(format: "anulada == NO")])
    }

    private func intervalo(_ periodo: PeriodoVentas, fecha: Date, calendario: Calendar) throws -> DateInterval {
        guard let intervalo = periodo.intervalo(en: fecha, calendario: calendario) else {
            throw ErrorVentas.calendarioInvalido
        }
        return intervalo
    }

    private func filtroFechas(_ intervalo: DateInterval) -> NSPredicate {
        NSPredicate(format: "fecha >= %@ AND fecha < %@", argumentArray: [intervalo.start, intervalo.end])
    }

    private func total(_ ventas: [Venta]) -> Decimal {
        ventas.reduce(Decimal.zero) { $0 + importe($1.total) }
    }
}
