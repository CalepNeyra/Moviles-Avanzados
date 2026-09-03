//
//  Biblioteca.swift
//  Laboratorio00
//
//  Created by Tecsup on 27/08/26.
//

import Foundation

let formatoFecha = DateFormatter()
formatoFecha.dateFormat = "dd/MM/yyyy"
formatoFecha.locale = Locale(identifier: "es_PE")
// Evita conversiones aproximadas o fechas inexistentes
formatoFecha.isLenient = false

let calendario = Calendar.current

// 1. INGRESO DE DATOS
print("--- SISTEMA DE CONTROL DE BIBLIOTECA ---")

print("Ingrese el título del libro:")
let tituloLibro = readLine() ?? "Libro General"

print("Seleccione tipo de usuario (1: Alumno [7 días], 2: Docente [15 días], 3: Administrativo [10 días]):")
let tipoOpcion = Int(readLine() ?? "1") ?? 1

// Validación estricta: Fecha de Préstamo
print("Ingrese la Fecha de Préstamo (formato obligatorio dd/MM/yyyy, ej: 01/01/2026):")
let entradaFechaPrestamo = readLine() ?? ""

guard entradaFechaPrestamo.count == 10,
      let fechaPrestamo = formatoFecha.date(from: entradaFechaPrestamo) else {
    print("❌ Error: Fecha de préstamo inválida. Debe respetar el formato de 2 dígitos dd/MM/yyyy (ej: 01/01/2026).")
    exit(1)
}

// Validación estricta: Fecha de Devolución
print("Ingrese la Fecha de Devolución (formato obligatorio dd/MM/yyyy, ej: 10/01/2026):")
let entradaFechaDevolucion = readLine() ?? ""

guard entradaFechaDevolucion.count == 10,
      let fechaDevolucion = formatoFecha.date(from: entradaFechaDevolucion) else {
    print("❌ Error: Fecha de devolución inválida. Debe respetar el formato de 2 dígitos dd/MM/yyyy (ej: 10/01/2026).")
    exit(1)
}

// Validación de orden temporal
if fechaDevolucion < fechaPrestamo {
    print("❌ Error: La fecha de devolución no puede ser anterior a la fecha de préstamo.")
    exit(1)
}


// 2. CONFIGURACIÓN SEGÚN TIPO DE USUARIO
var tarifaBase: Double = 0.0
var tipoNombre: String = ""
var diasMaximoPermitido: Int = 0

switch tipoOpcion {
case 1:
    tarifaBase = 1.50
    tipoNombre = "Alumno"
    diasMaximoPermitido = 7
case 2:
    tarifaBase = 2.00
    tipoNombre = "Docente"
    diasMaximoPermitido = 15
case 3:
    tarifaBase = 3.00
    tipoNombre = "Administrativo"
    diasMaximoPermitido = 10
default:
    tarifaBase = 1.50
    tipoNombre = "Alumno"
    diasMaximoPermitido = 7
}


// 3. CÁLCULO DE FECHA LÍMITE Y DÍAS DE ATRASO
let fechaLimite = calendario.date(byAdding: .day, value: diasMaximoPermitido, to: fechaPrestamo) ?? fechaPrestamo

let componentesTotales = calendario.dateComponents([.day], from: fechaPrestamo, to: fechaDevolucion)
let diasTotales = max(0, componentesTotales.day ?? 0)

let componentesAtraso = calendario.dateComponents([.day], from: fechaLimite, to: fechaDevolucion)
let diasAtraso = max(0, componentesAtraso.day ?? 0)


// 4. GENERACIÓN DE TABLA DÍA POR DÍA DE MORA
var acumuladoMulta: Double = 0.0

print("\n--- DETALLE DE MORA POR DÍA ---")
print("Día\tFecha\t\tMulta Día\tAcumulado")
print("--------------------------------------------------")

if diasAtraso > 0 {
    for dia in 1...diasAtraso {
        var tarifaDia: Double = 0.0
        
        if dia == 1 {
            tarifaDia = 0.0
        } else if dia >= 2 && dia <= 3 {
            tarifaDia = tarifaBase
        } else if dia >= 4 && dia <= 6 {
            tarifaDia = tarifaBase * 1.50
        } else {
            tarifaDia = tarifaBase * 2.00
        }
        
        acumuladoMulta += tarifaDia
        
        let fechaDiaMora = calendario.date(byAdding: .day, value: dia, to: fechaLimite) ?? fechaLimite
        let fechaDiaTexto = formatoFecha.string(from: fechaDiaMora)
        
        print("\(dia)\t\(fechaDiaTexto)\tS/ \(tarifaDia)\t\tS/ \(acumuladoMulta)")
    }
} else {
    print("Devolución entregada a tiempo. Sin días de mora.")
}
print("--------------------------------------------------")


// 5. CÁLCULO DE ESTADO Y SITUACIÓN
let estado = (diasAtraso > 0) ? "Devuelto con atraso" : "Devuelto sin atraso"
let situacion = (diasAtraso >= 10) ? "Suspendido" : "Habilitado"


// 6. RESUMEN FINAL
print("\n================== RESUMEN DEL PRÉSTAMO ==================")
print("Libro:                \(tituloLibro)")
print("Tipo de Usuario:      \(tipoNombre)")
print("----------------------------------------------------------")
print("Fecha de Préstamo:    \(formatoFecha.string(from: fechaPrestamo))")
print("Fecha Límite:         \(formatoFecha.string(from: fechaLimite)) (Plazo: \(diasMaximoPermitido) días)")
print("Fecha de Devolución:  \(formatoFecha.string(from: fechaDevolucion))")
print("Días Transcurridos:   \(diasTotales) días")
print("Días de Atraso:       \(diasAtraso) días")
print("----------------------------------------------------------")
print("Total a pagar:        S/ \(acumuladoMulta)")
print("Estado:               \(estado)")
print("Situación:            \(situacion)")
print("==========================================================")