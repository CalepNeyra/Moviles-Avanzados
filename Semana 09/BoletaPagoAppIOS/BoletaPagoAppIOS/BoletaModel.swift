//
//  BoletaModel.swift
//  BoletaPagoAppIOS
//
//  Created by Tecsup on 27/10/26.
//

import Foundation

// Extensión para cumplir estrictamente con la Regla 1 del Excel:
// Redondear cada concepto monetario individualmente a dos decimales antes de sumarlos.
extension Double {
    func roundedToTwoDecimals() -> Double {
        return (self * 100).rounded() / 100
    }
}

struct BoletaModel {
    // Parámetros normativos y constantes oficiales (Sincronizados con la pestaña 'Parámetros')
    static let rmv: Double = 1230.0
    static let tasaONP: Double = 0.13
    static let tasaEsSalud: Double = 0.09
    static let factorHE25: Double = 1.25
    static let factorHE35: Double = 1.35
    
    // Entradas editables del usuario o de los casos de prueba
    var sueldoBasico: Double
    var diasLaborados: Double
    var tieneHijos: Bool
    var sistemaPensiones: String // "ONP" o "AFP"
    var afpSeleccionada: String  // "AFP Ejemplo", "Habitat", "Integra", "Prima", "Profuturo"
    var horas25: Double
    var horas35: Double
    var adelanto: Double
    
    // --- BLOQUE 1: CÁLCULOS BASE Y REMUNERACIONES ---
    
    // Sueldo por día y valor hora conservan decimales intermedios según Regla 2 del Excel
    var sueldoDiarioBase: Double { sueldoBasico / 30.0 }
    var valorHoraBase: Double { sueldoDiarioBase / 8.0 }
    
    // Sueldo computable proporcional a los días laborados
    var sueldoComputable: Double { 
        (sueldoDiarioBase * diasLaborados).roundedToTwoDecimals() 
    }
    
    // Asignación familiar: 10% de la RMV si tiene hijos (No se prorratea por días)
    var asignacionFamiliar: Double { 
        tieneHijos ? (BoletaModel.rmv * 0.10).roundedToTwoDecimals() : 0.0 
    }
    
    // Horas extras al 25% y 35%
    var montoHE25: Double { 
        (valorHoraBase * BoletaModel.factorHE25 * horas25).roundedToTwoDecimals() 
    }
    var montoHE35: Double { 
        (valorHoraBase * BoletaModel.factorHE35 * horas35).roundedToTwoDecimals() 
    }
    
    // Total de ingresos remunerativos
    var totalRemuneraciones: Double {
        (sueldoComputable + asignacionFamiliar + montoHE25 + montoHE35).roundedToTwoDecimals()
    }
    
    // --- BLOQUE 2: RETENCIONES Y DESCUENTOS ---
    
    // ONP (13% aplicado solo si el sistema elegido es ONP)
    var montoONP: Double {
        sistemaPensiones == "ONP" ? (totalRemuneraciones * BoletaModel.tasaONP).roundedToTwoDecimals() : 0.0
    }
    
    // Tasas de AFP (Equivalente al BUSCARV de la tabla de parámetros del Excel)
    private var tasasAFP: (fondo: Double, comision: Double, seguro: Double) {
        switch afpSeleccionada {
        case "Habitat (flujo)":   return (0.10, 0.0147, 0.0137)
        case "Integra (flujo)":   return (0.10, 0.0155, 0.0137)
        case "Prima (flujo)":     return (0.10, 0.0160, 0.0137)
        case "Profuturo (flujo)": return (0.10, 0.0169, 0.0137)
        default:                  return (0.10, 0.0160, 0.0135) // AFP Ejemplo corporativo
        }
    }
    
    var afpFondo: Double {
        sistemaPensiones == "AFP" ? (totalRemuneraciones * tasasAFP.fondo).roundedToTwoDecimals() : 0.0
    }
    
    var afpComision: Double {
        sistemaPensiones == "AFP" ? (totalRemuneraciones * tasasAFP.comision).roundedToTwoDecimals() : 0.0
    }
    
    var afpSeguro: Double {
        sistemaPensiones == "AFP" ? (totalRemuneraciones * tasasAFP.seguro).roundedToTwoDecimals() : 0.0
    }
    
    // Total de descuentos (Suma de retención de pensión + adelantos recibidos)
    var totalDescuentos: Double {
        (montoONP + afpFondo + afpComision + afpSeguro + adelanto).roundedToTwoDecimals()
    }
    
    // --- BLOQUE 3: NETO A PAGAR Y APORTES EMPLEADOR ---
    
    // Líquido final a recibir por el trabajador
    var netoAPagar: Double {
        (totalRemuneraciones - totalDescuentos).roundedToTwoDecimals()
    }
    
    // EsSalud a cargo del empleador (9%, no se descuenta al trabajador)
    var esSaludEmpleador: Double {
        (totalRemuneraciones * BoletaModel.tasaEsSalud).roundedToTwoDecimals()
    }
    
    // Costo total para la empresa
    var costoTotalEmpleador: Double {
        (totalRemuneraciones + esSaludEmpleador).roundedToTwoDecimals()
    }
}
