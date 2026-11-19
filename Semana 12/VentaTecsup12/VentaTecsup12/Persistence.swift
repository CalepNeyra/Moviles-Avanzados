import CoreData

@MainActor
final class RepositorioVentas {
    static let modelo = "VentaTecsup12"
    private let store: NSPersistentContainer
    private var contexto: NSManagedObjectContext { store.viewContext }
    private var sesion: Usuario?

    init(url: URL? = nil) throws {
        guard let recurso = Bundle.main.url(forResource: Self.modelo, withExtension: "momd"),
              let modelo = NSManagedObjectModel(contentsOf: recurso) else { throw ErrorVentas.modeloNoDisponible }
        store = NSPersistentContainer(name: Self.modelo, managedObjectModel: modelo)
        let destino = url ?? NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Ventas.sqlite")
        try FileManager.default.createDirectory(at: destino.deletingLastPathComponent(), withIntermediateDirectories: true)
        try store.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: destino)
    }

    func disponible(_ usuario: String) throws -> Bool {
        let usuario = ReglasVentas.normalizarUsuario(usuario)
        return try !usuario.isEmpty && buscarUsuario(usuario) == nil
    }

    @discardableResult
    func registrarUsuario(nombre: String, usuario: String, clave: String, confirmacion: String, rol: Rol) throws -> Usuario {
        let nombre = try obligatorio(nombre)
        let usuario = try obligatorio(ReglasVentas.normalizarUsuario(usuario))
        guard clave.count >= 6 else { throw ErrorVentas.claveCorta }
        guard clave == confirmacion else { throw ErrorVentas.clavesDistintas }
        guard try disponible(usuario) else { throw ErrorVentas.usuarioOcupado }
        let protegida = try Clave.proteger(clave)
        let nuevo = Usuario(context: contexto)
        nuevo.nombre = nombre
        nuevo.usuario = usuario
        nuevo.clave = protegida
        nuevo.rol = rol.rawValue
        try guardar()
        sesion = nuevo
        return nuevo
    }

    @discardableResult
    func acceder(usuario: String, clave: String) throws -> Usuario {
        guard let cuenta = try buscarUsuario(ReglasVentas.normalizarUsuario(usuario)),
              Rol(rawValue: cuenta.rol) != nil, try Clave.validar(clave, guardada: cuenta.clave) else {
            throw ErrorVentas.credencialesInvalidas
        }
        sesion = cuenta
        return cuenta
    }

    func salir() { sesion = nil }

    @discardableResult
    func exigirSesion(_ rol: Rol? = nil) throws -> Usuario {
        guard let sesion else { throw ErrorVentas.sinSesion }
        if let rol, sesion.rol != rol.rawValue { throw ErrorVentas.permisoDenegado }
        return sesion
    }

    func productos(busqueda: String = "", categoria: String? = nil) throws -> [Producto] {
        try exigirSesion()
        var filtros = filtrosBusqueda(busqueda, formato: "nombre CONTAINS[cd] %@")
        if let categoria { filtros.append(NSPredicate(format: "categoria == %@", categoria)) }
        return try consultar(Producto.self, filtros, ordenar: "nombre")
    }

    func guardarProducto(_ registro: Producto?, nombre: String, categoria: String, precio: Decimal, stock: Int64) throws -> Producto {
        try exigirSesion(.supervisor)
        let nombre = try obligatorio(nombre)
        let categoria = try obligatorio(categoria)
        guard precio > 0, precio == redondear(precio) else { throw ErrorVentas.precioInvalido }
        let precioGuardado = try importeGuardable(precio)
        guard stock >= 0 else { throw ErrorVentas.stockInvalido }
        if let registro { try verificar(registro) }
        let producto = registro ?? Producto(context: contexto)
        producto.nombre = nombre
        producto.categoria = categoria
        producto.precio = precioGuardado
        producto.stock = stock
        try guardar()
        return producto
    }

    func borrarProducto(_ producto: Producto) throws {
        try exigirSesion(.supervisor)
        try borrar(producto, tieneVentas: (producto.ventas?.count ?? 0) > 0)
    }

    func clientes(busqueda: String = "") throws -> [Cliente] {
        try exigirSesion()
        let texto = limpio(busqueda)
        let filtros = texto.isEmpty ? [] : [NSPredicate(format: "nombre CONTAINS[cd] %@ OR documento CONTAINS[cd] %@", texto, texto)]
        return try consultar(Cliente.self, filtros, ordenar: "nombre")
    }

    func guardarCliente(_ registro: Cliente?, nombre: String, documento: String) throws -> Cliente {
        try exigirSesion()
        let nombre = try obligatorio(nombre)
        let documento = try obligatorio(documento)
        if let registro { try verificar(registro) }
        let cliente = registro ?? Cliente(context: contexto)
        cliente.nombre = nombre
        cliente.documento = documento
        try guardar()
        return cliente
    }

    func borrarCliente(_ cliente: Cliente) throws {
        try exigirSesion(.supervisor)
        try borrar(cliente, tieneVentas: (cliente.ventas?.count ?? 0) > 0)
    }

    func perfiles(busqueda: String) throws -> [FilaCliente] {
        try clientes(busqueda: busqueda).map { cliente in
            let compras = comprado(cliente)
            return FilaCliente(cliente: cliente, totalComprado: compras, categoria: CategoriaCliente(compras: compras))
        }
    }

    func cotizar(producto: Producto, cliente: Cliente, cantidad: Int64) throws -> ImportesVenta {
        try exigirSesion(.vendedor)
        try verificar(producto)
        try verificar(cliente)
        guard cantidad > 0 else { throw ErrorVentas.cantidadInvalida }
        guard cantidad <= producto.stock else { throw ErrorVentas.stockInsuficiente(producto.stock) }
        return ImportesVenta(precio: decimal(producto.precio), cantidad: cantidad,
                             categoria: CategoriaCliente(compras: comprado(cliente)))
    }

    @discardableResult
    func vender(producto: Producto, cliente: Cliente, cantidad: Int64, fecha: Date = .now) throws -> Venta {
        let vendedor = try exigirSesion(.vendedor)
        let importes = try cotizar(producto: producto, cliente: cliente, cantidad: cantidad)
        let descuento = try importeGuardable(importes.descuento)
        let igv = try importeGuardable(importes.igv)
        let total = try importeGuardable(importes.total)
        let venta = Venta(context: contexto)
        venta.fecha = fecha
        venta.cantidad = cantidad
        venta.precioUnitario = producto.precio
        venta.descuento = descuento
        venta.igv = igv
        venta.total = total
        venta.producto = producto
        venta.cliente = cliente
        venta.vendedor = vendedor
        producto.stock -= cantidad
        try guardar()
        return venta
    }

    func anular(_ venta: Venta, motivo: String) throws {
        try exigirSesion(.supervisor)
        try verificar(venta)
        guard !venta.anulada else { throw ErrorVentas.anulada }
        let motivo = limpio(motivo)
        guard !motivo.isEmpty else { throw ErrorVentas.motivoRequerido }
        let (stock, exceso) = venta.producto.stock.addingReportingOverflow(venta.cantidad)
        guard !exceso else { throw ErrorVentas.stockInvalido }
        venta.anulada = true
        venta.motivoAnulacion = motivo
        venta.producto.stock = stock
        try guardar()
    }

    func vendedores() throws -> [Usuario] {
        try exigirSesion(.supervisor)
        return try consultar(Usuario.self, [NSPredicate(format: "rol == %@", Rol.vendedor.rawValue)], ordenar: "nombre")
    }

    func misVentas(periodo: PeriodoVentas, cliente: String) throws -> [Venta] {
        let vendedor = try exigirSesion(.vendedor)
        return try historial(periodo: periodo, cliente: cliente, vendedor: vendedor)
    }

    func ventasEquipo(periodo: PeriodoVentas, vendedor: Usuario?, cliente: String) throws -> [Venta] {
        try exigirSesion(.supervisor)
        return try historial(periodo: periodo, cliente: cliente, vendedor: vendedor)
    }

    private func historial(periodo: PeriodoVentas, cliente: String, vendedor: Usuario?) throws -> [Venta] {
        var filtros = filtrosBusqueda(cliente, formato: "cliente.nombre CONTAINS[cd] %@")
        if let vendedor {
            try verificar(vendedor)
            filtros.append(NSPredicate(format: "vendedor == %@", argumentArray: [vendedor]))
        }
        if periodo != .todas {
            filtros.append(filtroFecha(try intervalo(periodo == .hoy ? .day : .month)))
        }
        return try consultar(Venta.self, filtros, ordenar: "fecha", ascendente: false)
    }

    func indicadores() throws -> IndicadoresVentas {
        let vendedor = try exigirSesion(.vendedor)
        let filtro = NSPredicate(format: "vendedor == %@", argumentArray: [vendedor])
        let hoy = try vigentes(try intervalo(.day), filtros: [filtro])
        let mes = try vigentes(try intervalo(.month), filtros: [filtro])
        return IndicadoresVentas(totalHoy: total(hoy), cantidadHoy: hoy.count, totalMes: total(mes), cantidadMes: mes.count)
    }

    func resumen() throws -> ResumenSupervisor {
        try exigirSesion(.supervisor)
        let calendario = Calendar.current
        let hoy = try intervalo(.day)
        let fechas = (-6...0).compactMap { calendario.date(byAdding: .day, value: $0, to: hoy.start) }
        guard fechas.count == 7, let primero = fechas.first else { throw ErrorVentas.registroInvalido }
        let recientes = try vigentes(DateInterval(start: primero, end: hoy.end))
        let grupos = Dictionary(grouping: recientes) { calendario.startOfDay(for: $0.fecha) }
        let dias = fechas.map { TotalDiario(fecha: $0, total: total(grupos[$0] ?? [])) }
        let hoyTotal = dias[6].total
        let ayerTotal = dias[5].total
        let mes = try vigentes(try intervalo(.month))
        let porVendedor = Dictionary(grouping: mes) { $0.vendedor.objectID }
        var ranking: [TotalVendedor] = []
        for ventas in porVendedor.values {
            guard let venta = ventas.first else { continue }
            ranking.append(TotalVendedor(nombre: venta.vendedor.nombre, total: total(ventas)))
        }
        ranking.sort {
            if $0.total == $1.total { return $0.nombre < $1.nombre }
            return $0.total > $1.total
        }
        let bajo = try consultar(Producto.self, [NSPredicate(format: "stock <= 5")], ordenar: "stock")
        return ResumenSupervisor(totalHoy: hoyTotal,
                                 variacionRespectoAyer: ayerTotal == 0 ? nil : redondear((hoyTotal - ayerTotal) * 100 / ayerTotal),
                                 igvMes: mes.reduce(0) { $0 + decimal($1.igv) },
                                 ultimosSieteDias: dias, rankingVendedores: ranking, stockBajo: bajo)
    }

    private func buscarUsuario(_ usuario: String) throws -> Usuario? {
        try consultar(Usuario.self, [NSPredicate(format: "usuario == %@", usuario)], limite: 1).first
    }

    private func comprado(_ cliente: Cliente) -> Decimal {
        let ventas = cliente.ventas?.allObjects.compactMap { $0 as? Venta } ?? []
        return total(ventas.filter { !$0.anulada })
    }

    private func total(_ ventas: [Venta]) -> Decimal {
        ventas.reduce(0) { $0 + decimal($1.total) }
    }

    private func vigentes(_ intervalo: DateInterval, filtros: [NSPredicate] = []) throws -> [Venta] {
        try consultar(Venta.self, filtros + [filtroFecha(intervalo), NSPredicate(format: "anulada == NO")])
    }

    private func intervalo(_ componente: Calendar.Component) throws -> DateInterval {
        guard let intervalo = Calendar.current.dateInterval(of: componente, for: .now) else { throw ErrorVentas.registroInvalido }
        return intervalo
    }

    private func filtroFecha(_ intervalo: DateInterval) -> NSPredicate {
        NSPredicate(format: "fecha >= %@ AND fecha < %@", argumentArray: [intervalo.start, intervalo.end])
    }

    private func filtrosBusqueda(_ texto: String, formato: String) -> [NSPredicate] {
        let texto = limpio(texto)
        return texto.isEmpty ? [] : [NSPredicate(format: formato, texto)]
    }

    private func consultar<T: NSManagedObject>(_ tipo: T.Type, _ filtros: [NSPredicate],
                                               ordenar: String? = nil, ascendente: Bool = true, limite: Int = 0) throws -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: tipo))
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: filtros)
        if let ordenar { request.sortDescriptors = [NSSortDescriptor(key: ordenar, ascending: ascendente)] }
        request.fetchLimit = limite
        return try contexto.fetch(request)
    }

    private func verificar(_ registro: NSManagedObject) throws {
        guard registro.managedObjectContext === contexto, !registro.isDeleted else { throw ErrorVentas.registroInvalido }
    }

    private func borrar(_ registro: NSManagedObject, tieneVentas: @autoclosure () -> Bool) throws {
        try verificar(registro)
        guard !tieneVentas() else { throw ErrorVentas.tieneVentas }
        contexto.delete(registro)
        try guardar()
    }

    private func limpio(_ texto: String) -> String { texto.trimmingCharacters(in: .whitespacesAndNewlines) }

    private func obligatorio(_ texto: String) throws -> String {
        let texto = limpio(texto)
        guard !texto.isEmpty else { throw ErrorVentas.camposRequeridos }
        return texto
    }

    private func importeGuardable(_ precio: Decimal) throws -> Double {
        let valor = NSDecimalNumber(decimal: precio).doubleValue
        guard valor.isFinite, decimal(valor) == precio else { throw ErrorVentas.precioInvalido }
        return valor
    }

    private func guardar() throws {
        do { try contexto.save() }
        catch {
            contexto.rollback()
            throw error
        }
    }
}

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
