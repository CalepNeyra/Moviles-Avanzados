//
//  BoletaModel.swift
//  BoletaPagoAppIOS
//
//  Created by Tecsup on 27/10/26.
//

import Foundation

struct BoletaCalculadora {
    // Parámetros normativos fijos
    let rmv: Double = 1230.00
    
    // Resultados de Remuneraciones
    var sueldoComputable: Double = 0.0
    var asignacionFamiliar: Double = 0.0
    var montoHE25: Double = 0.0
    var montoHE35: Double = 0.0
    var totalRemuneraciones: Double = 0.0
    
    // Resultados de Descuentos
    var montoONP: Double = 0.0
    var montoAFPFondo: Double = 0.0
    var montoAFPComision: Double = 0.0
    var montoAFPSeguro: Double = 0.0
    var montoAdelantos: Double = 0.0
    var totalDescuentos: Double = 0.0
    
    // Aportaciones del Empleador
    var esSaludEmpleador: Double = 0.0
    
    // Neto a Pagar
    var netoAPagar: Double = 0.0

    mutating func calcular(
        sueldoBasico: Double,
        diasLaborados: Int,
        tieneHijos: Bool,
        esONP: Bool,
        horas25: Double,
        horas35: Double,
        adelantos: Double
    ) {
        // 1. Sueldo computable (Sueldo / 30 * Días) redondeado a 2 decimales
        let brutoDiario = sueldoBasico / 30.0
        sueldoComputable = round((brutoDiario * Double(diasLaborados)) * 100) / 100
        
        // 2. Asignación familiar (10% de la RMV si tiene hijos, de lo contrario 0)
        asignacionFamiliar = tieneHijos ? round((rmv * 0.10) * 100) / 100 : 0.0
        
        // 3. Valor hora y Horas Extras (25% y 35%)
        let valorHora = (sueldoBasico / 30.0) / 8.0
        montoHE25 = round((valorHora * 1.25 * horas25) * 100) / 100
        montoHE35 = round((valorHora * 1.35 * horas35) * 100) / 100
        
        // Total Remuneraciones
        totalRemuneraciones = round((sueldoComputable + asignacionFamiliar + montoHE25 + montoHE35) * 100) / 100
        
        // 4. Retenciones y Descuentos (Con ceros estrictos en los no aplicables)
        if esONP {
            montoONP = round((totalRemuneraciones * 0.13) * 100) / 100
            montoAFPFondo = 0.0
            montoAFPComision = 0.0
            montoAFPSeguro = 0.0
        } else {
            montoONP = 0.0
            // AFP Ejemplo: Fondo 10%, Comisión 1.60%, Seguro 1.35% (Total 12.95%)
            montoAFPFondo = round((totalRemuneraciones * 0.10) * 100) / 100
            montoAFPComision = round((totalRemuneraciones * 0.0160) * 100) / 100
            montoAFPSeguro = round((totalRemuneraciones * 0.0135) * 100) / 100
        }
        
        montoAdelantos = round(adelantos * 100) / 100
        
        let sumaDescuentos = montoONP + montoAFPFondo + montoAFPComision + montoAFPSeguro + montoAdelantos
        totalDescuentos = round(sumaDescuentos * 100) / 100
        
        // 5. Aportaciones del Empleador (EsSalud 9%)
        esSaludEmpleador = round((totalRemuneraciones * 0.09) * 100) / 100
        
        // 6. Neto a Pagar
        netoAPagar = round((totalRemuneraciones - totalDescuentos) * 100) / 100
    }
}
