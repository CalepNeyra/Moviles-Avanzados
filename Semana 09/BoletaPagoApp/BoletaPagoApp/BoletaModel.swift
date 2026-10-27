//
//  BoletaModel.swift
//  BoletaPagoApp
//
//  Created by Tecsup on 27/10/26.
//

import Foundation

// MARK: - Modelo de Cálculo (Backend)
class BoletaCalculadora {
    
    // Parámetros fijos centralizados (según la guía del proyecto)
    let rmv: Double = 1230.00          // Remuneración Mínima Vital (Octubre 2026)[cite: 1]
    let tasaEsSalud: Double = 0.09     // Aportación del empleador (9%)[cite: 1]
    let tasaONP: Double = 0.13         // Descuento ONP (13%)[cite: 1]
    
    // Tasas de AFP de prueba para los casos[cite: 1]
    let afpFondoTasa: Double = 0.10     // 10.00%
    let afpComisionTasa: Double = 0.0160 // 1.60%
    let afpSeguroTasa: Double = 0.0135  // 1.35%
    
    // Resultados de Salida
    var sueldoComputable: Double = 0.0
    var asignacionFamiliar: Double = 0.0
    var montoHE25: Double = 0.0
    var montoHE35: Double = 0.0
    var totalRemuneraciones: Double = 0.0
    
    var montoONP: Double = 0.0
    var montoAFPFondo: Double = 0.0
    var montoAFPComision: Double = 0.0
    var montoAFPSeguro: Double = 0.0
    var montoAdelantos: Double = 0.0
    var totalDescuentos: Double = 0.0
    
    var netoAPagar: Double = 0.0
    var esSaludEmpleador: Double = 0.0

    // Función principal que ejecuta las reglas de cálculo[cite: 1]
    func calcular(sueldoBasico: Double, diasLaborados: Int, tieneHijos: Bool, esONP: Bool, horas25: Double, horas35: Double, adelantos: Double) {
        
        // 1. Sueldo computable: Sueldo básico ÷ 30 × días laborados[cite: 1]
        let scRaw = (sueldoBasico / 30.0) * Double(diasLaborados)
        sueldoComputable = redondear(scRaw)
        
        // 2. Asignación familiar: 10% de la RMV si tiene hijos (no se prorratea)[cite: 1]
        asignacionFamiliar = tieneHijos ? redondear(rmv * 0.10) : 0.0
        
        // 3. Horas extras (al 25% y 35%)[cite: 1]
        let valorHora = (sueldoBasico / 30.0) / 8.0
        montoHE25 = redondear(valorHora * 1.25 * horas25)
        montoHE35 = redondear(valorHora * 1.35 * horas35)
        
        // 4. Total remuneraciones[cite: 1]
        totalRemuneraciones = redondear(sueldoComputable + asignacionFamiliar + montoHE25 + montoHE35)
        
        // 5. Retenciones / Descuentos[cite: 1]
        if esONP {
            montoONP = redondear(totalRemuneraciones * tasaONP)
            montoAFPFondo = 0.0
            montoAFPComision = 0.0
            montoAFPSeguro = 0.0
        } else {
            montoONP = 0.0
            montoAFPFondo = redondear(totalRemuneraciones * afpFondoTasa)
            montoAFPComision = redondear(totalRemuneraciones * afpComisionTasa)
            montoAFPSeguro = redondear(totalRemuneraciones * afpSeguroTasa)
        }
        
        montoAdelantos = redondear(adelantos)
        
        let pensionTotal = esONP ? montoONP : (montoAFPFondo + montoAFPComision + montoAFPSeguro)
        totalDescuentos = redondear(pensionTotal + montoAdelantos)
        
        // 6. Neto a pagar y EsSalud[cite: 1]
        netoAPagar = redondear(totalRemuneraciones - totalDescuentos)
        esSaludEmpleador = redondear(totalRemuneraciones * tasaEsSalud)
    }
    
    // Convención de redondeo estricto a 2 decimales[cite: 1]
    private func redondear(_ valor: Double) -> Double {
        return (valor * 100).rounded() / 100
    }
}
