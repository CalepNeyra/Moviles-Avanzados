import Foundation

enum Rol: String, CaseIterable {
    case vendedor = "Vendedor"
    case supervisor = "Supervisor"
}

enum CategoriaCliente: String {
    case regular = "Regular", frecuente = "Frecuente", vip = "VIP"

    init(compras: Decimal) {
        if compras >= 5000 { self = .vip }
        else if compras >= 1000 { self = .frecuente }
        else { self = .regular }
    }
}

enum NivelStock {
    case bajo, medio, alto

    init(unidades: Int64) {
        switch unidades {
        case ...5: self = .bajo
        case 6...10: self = .medio
        default: self = .alto
        }
    }
}

enum PeriodoVentas {
    case todas, hoy, mes
}

struct ImportesVenta {
    let subtotal: Decimal
    let categoria: CategoriaCliente
    let descuento: Decimal
    let igv: Decimal
    let total: Decimal

    init(precio: Decimal, cantidad: Int64, categoria: CategoriaCliente) {
        subtotal = redondear(precio * Decimal(cantidad))
        self.categoria = categoria
        descuento = categoria == .vip ? redondear(subtotal / 10) : 0
        igv = redondear((subtotal - descuento) * 18 / 100)
        total = subtotal - descuento + igv
    }
}

func redondear(_ valor: Decimal) -> Decimal {
    var entrada = valor
    var salida = Decimal.zero
    NSDecimalRound(&salida, &entrada, 2, .plain)
    return salida
}

func decimal(_ valor: Double) -> Decimal {
    Decimal(string: String(valor), locale: Locale(identifier: "en_US_POSIX")) ?? .nan
}

enum ReglasVentas {
    static func normalizarUsuario(_ usuario: String) -> String {
        usuario.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().precomposedStringWithCanonicalMapping
    }
}

enum ErrorVentas: LocalizedError {
    case modeloNoDisponible, camposRequeridos, claveCorta, clavesDistintas, usuarioOcupado
    case credencialesInvalidas, sinSesion, permisoDenegado, precioInvalido, stockInvalido
    case cantidadInvalida, stockInsuficiente(Int64), tieneVentas, motivoRequerido, anulada, registroInvalido

    var errorDescription: String? {
        switch self {
        case .modeloNoDisponible: return "No se pudo abrir el modelo de Ventas Tecsup."
        case .camposRequeridos: return "Completa los campos obligatorios."
        case .claveCorta: return "La clave debe tener al menos seis caracteres."
        case .clavesDistintas: return "Las claves no coinciden."
        case .usuarioOcupado: return "El usuario ya existe."
        case .credencialesInvalidas: return "Usuario o clave incorrectos"
        case .sinSesion: return "Inicia sesión para continuar."
        case .permisoDenegado: return "Tu rol no permite esta operación."
        case .precioInvalido: return "Ingresa un precio válido y mayor que cero."
        case .stockInvalido: return "El stock debe ser un número entero válido."
        case .cantidadInvalida: return "La cantidad debe ser mayor que cero."
        case .stockInsuficiente(let stock): return "Stock insuficiente. Disponibles: \(stock)."
        case .tieneVentas: return "El registro tiene ventas asociadas y no puede borrarse."
        case .motivoRequerido: return "Ingresa el motivo de anulación."
        case .anulada: return "La venta ya está anulada."
        case .registroInvalido: return "El registro ya no está disponible."
        }
    }
}
