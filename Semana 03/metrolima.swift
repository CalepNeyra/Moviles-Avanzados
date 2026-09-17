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
