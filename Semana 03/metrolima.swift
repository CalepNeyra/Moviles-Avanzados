// ============================================================================
// ESTUDIANTE: Calep Omar Neyra Taype
// CURSO: Programación Móvil Avanzada
// DOCENTE: Juan León
// INSTITUCIÓN: Tecsup
// PROYECTO: Sistema del Metro de Lima y Callao (Línea 1 y Línea 2)
// UBICACIÓN: Semana 03 / Tareametro.swift
// ============================================================================

import Foundation

// ============================================================================
// FORMATO Y SECUENCIAS ANSI PARA LA CONSOLA
// ============================================================================
extension String {
    var negrita: String { "\u{001B}[1m\(self)\u{001B}[0m" }
    var subrayado: String { "\u{001B}[4m\(self)\u{001B}[0m" }
    var verde: String { "\u{001B}[32m\(self)\u{001B}[0m" }
    var rojo: String { "\u{001B}[31m\(self)\u{001B}[0m" }
    var amarillo: String { "\u{001B}[33m\(self)\u{001B}[0m" }
    var azul: String { "\u{001B}[34m\(self)\u{001B}[0m" }
    var cian: String { "\u{001B}[36m\(self)\u{001B}[0m" }
}
// ============================================================================
// 1. ESTADO DE OPERATIVIDAD
// ============================================================================
enum EstadoServicio {
    case operativo
    case fueraDeServicio
    
    var indicador: String {
        switch self {
        case .operativo: return "(F)"
        case .fueraDeServicio: return "(NF)"
        }
    }
    
    var etiquetaVisible: String {
        switch self {
        case .operativo: return "🟢 OPERATIVA (En servicio comercial)".verde.negrita
        case .fueraDeServicio: return "🔴 NO OPERATIVA (En construcción / obras)".rojo.negrita
        }
    }
}
// ============================================================================
// 2. MODELO DE ESTACIÓN REAL
// ============================================================================
struct EstacionRed {
    let identificador: String
    let nombre: String
    let lineaPertenencia: String
    let posicion: Int
    let estado: EstadoServicio
    let accesoDiscapacidad: Bool
    let cruceAvenidas: String
    let puntosInteres: [String]
    
    func obtenerFichaDetallada(tarifa: Double) -> String {
        let cod = identificador.isEmpty ? "" : "[\(identificador)] "
        let accTexto = accesoDiscapacidad ? "♿ Accesible (Ascensores / Rampas)".verde : "🚫 Accesibilidad restringida por obras".rojo
        
        return """
        --------------------------------------------------
        📍 ESTACIÓN: \(cod)\(nombre.uppercased())
        --------------------------------------------------
        • Estado de Operación : \(estado.etiquetaVisible)
        • Red / Línea         : \(lineaPertenencia.cian) (Posición \(posicion))
        • Tarifa Adulto       : S/ \(String(format: "%.2f", tarifa).amarillo)
        • Ubicación/Cruce     : \(cruceAvenidas)
        • Accesibilidad       : \(accTexto)
        • Referencias         : \(puntosInteres.joined(separator: ", "))
        --------------------------------------------------
        """
    }
}
// ============================================================================
// 3. MODELO DE LÍNEA Y TARIFARIO
// ============================================================================
struct LineaTransporte {
    let denominacion: String
    let colorIdentificador: String
    let tarifaAdulto: Double
    let tarifaMedio: Double
    var paraderos: [EstacionRed] = []
    
    func imprimirCatalogo() {
        print("\n==========================================")
        print("RED METROPOLITANA: \(denominacion.uppercased()) (\(colorIdentificador))".negrita.cian)
        print("💵 Tarifa General: S/ \(String(format: "%.2f", tarifaAdulto)) | Medio Pasaje: S/ \(String(format: "%.2f", tarifaMedio))".amarillo)
        print("==========================================")
        for p in paraderos {
            let cod = p.identificador.isEmpty ? "" : "[\(p.identificador)] "
            let estadoTexto = (p.estado == .operativo) ? "🟢 [OPERATIVA]".verde : "🔴 [EN OBRAS]".rojo
            print("  \(p.posicion). \(cod)\(p.nombre) \(estadoTexto) — \(p.cruceAvenidas)")
        }
        print("Total de estaciones: \(paraderos.count)")
    }
}
