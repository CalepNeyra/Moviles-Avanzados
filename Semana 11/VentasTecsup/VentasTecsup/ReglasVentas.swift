import Foundation

enum Rol: String, CaseIterable {
    case vendedor = "Vendedor"
    case supervisor = "Supervisor"
}

enum CategoriaCliente: String {
    case regular = "Regular"
    case frecuente = "Frecuente"
    case vip = "VIP"
}

enum NivelStock {
    case bajo
    case medio
    case alto

    init(unidades: Int64) {
        switch unidades {
        case ...5: self = .bajo
        case 6...10: self = .medio
        default: self = .alto
        }
    }
}

enum PeriodoVentas {
    case todas
    case hoy
    case mes

    func intervalo(en fecha: Date, calendario: Calendar) -> DateInterval? {
        switch self {
        case .todas: return nil
        case .hoy: return calendario.dateInterval(of: .day, for: fecha)
        case .mes: return calendario.dateInterval(of: .month, for: fecha)
        }
    }
}

struct ImportesVenta {
    let subtotal: Decimal
    let categoria: CategoriaCliente
    let descuento: Decimal
    let igv: Decimal
    let total: Decimal
}

enum ReglasVentas {
    // Valores provisionales: las capturas muestran ejemplos, sin los límites ni la tasa de Frecuente.
    static let minimoFrecuente: Decimal = 1_000
    static let minimoVIP: Decimal = 5_000
    static let descuentoFrecuente = Decimal(5) / 100

    static func normalizarUsuario(_ texto: String) -> String {
        texto.trimmingCharacters(in: .whitespacesAndNewlines)
            .precomposedStringWithCanonicalMapping
            .lowercased()
            .precomposedStringWithCanonicalMapping
    }

    static func categoria(totalComprado: Decimal) -> CategoriaCliente {
        if totalComprado >= minimoVIP { return .vip }
        if totalComprado >= minimoFrecuente { return .frecuente }
        return .regular
    }

    static func calcular(precioUnitario: Decimal, cantidad: Int64, categoria: CategoriaCliente) -> ImportesVenta {
        let tasa: Decimal
        switch categoria {
        case .regular: tasa = 0
        case .frecuente: tasa = descuentoFrecuente
        case .vip: tasa = Decimal(10) / 100
        }

        let subtotal = redondear(precioUnitario * Decimal(cantidad))
        let descuento = redondear(subtotal * tasa)
        let base = subtotal - descuento
        let igv = redondear(base * Decimal(18) / 100)
        return ImportesVenta(subtotal: subtotal, categoria: categoria, descuento: descuento, igv: igv, total: base + igv)
    }

    static func redondear(_ monto: Decimal) -> Decimal {
        var monto = monto
        var resultado = Decimal()
        NSDecimalRound(&resultado, &monto, 2, .plain)
        return resultado
    }
}

enum ErrorVentas: LocalizedError {
    case camposRequeridos
    case claveCorta
    case clavesDistintas
    case usuarioOcupado
    case credencialesInvalidas
    case sinSesion
    case permisoDenegado
    case objetoNoDisponible
    case precioInvalido
    case stockInvalido
    case cantidadInvalida
    case stockInsuficiente(disponible: Int64)
    case tieneVentas
    case motivoRequerido
    case ventaAnulada
    case calendarioInvalido
    case modeloNoDisponible
    case claveNoProcesada

    var errorDescription: String? {
        switch self {
        case .camposRequeridos: return "Completa los campos obligatorios."
        case .claveCorta: return "La clave debe tener como mínimo 6 caracteres."
        case .clavesDistintas: return "Las claves no coinciden."
        case .usuarioOcupado: return "El usuario ya existe."
        case .credencialesInvalidas: return "Usuario o clave incorrectos"
        case .sinSesion: return "Inicia sesión para continuar."
        case .permisoDenegado: return "Tu rol no permite esta operación."
        case .objetoNoDisponible: return "El registro seleccionado ya no está disponible."
        case .precioInvalido: return "Ingresa un precio válido y mayor que cero."
        case .stockInvalido: return "El stock debe estar dentro del rango permitido."
        case .cantidadInvalida: return "La cantidad debe ser mayor que cero."
        case .stockInsuficiente(let disponible): return "Stock insuficiente. Unidades disponibles: \(disponible)."
        case .tieneVentas: return "No se puede eliminar el registro porque tiene ventas asociadas."
        case .motivoRequerido: return "Ingresa el motivo de la anulación."
        case .ventaAnulada: return "La venta ya fue anulada."
        case .calendarioInvalido: return "No se pudo calcular el período de ventas."
        case .modeloNoDisponible: return "No se pudo abrir el modelo de Ventas Tecsup."
        case .claveNoProcesada: return "No se pudo procesar la clave."
        }
    }
}
