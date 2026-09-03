//
//  Biblioteca.swift
//  Laboratorio00
//

import Foundation

let formato = DateFormatter()
formato.dateFormat = "dd/MM/yyyy"
let cal = Calendar.current

// 1. ENTRADA DE DATOS
print("--- SISTEMA DE CONTROL DE BIBLIOTECA ---")

print("Título del libro:")
let titulo = readLine() ?? "Libro General"

print("Tipo de usuario (1: Alumno [7d], 2: Docente [15d], 3: Administrativo [10d]):")
let tipo = Int(readLine() ?? "1") ?? 1

print("Fecha Préstamo (dd/MM/yyyy):")
let fechaPrestamo = formato.date(from: readLine() ?? "")!

print("Fecha Devolución (dd/MM/yyyy):")
let fechaDevolucion = formato.date(from: readLine() ?? "")!

// 2. CONFIGURACIÓN SEGÚN TIPO
var tarifaBase = 1.50
var tipoNombre = "Alumno"
var diasPermitidos = 7

if tipo == 2 {
    tarifaBase = 2.00
    tipoNombre = "Docente"
    diasPermitidos = 15
} else if tipo == 3 {
    tarifaBase = 3.00
    tipoNombre = "Administrativo"
    diasPermitidos = 10
}

// 3. FECHA LÍMITE Y DÍAS DE ATRASO (Sin usar Calendar)

// Calcular fecha límite sumando los días en segundos
let segundosPorDia: TimeInterval = 86400
let fechaLimite = fechaPrestamo.addingTimeInterval(segundosPorDia * Double(diasPermitidos))

// Calcular días de atraso restando las fechas (nos da el tiempo en segundos)
let diferenciaSegundos = fechaDevolucion.timeIntervalSince(fechaLimite)

// Convertimos de segundos a días de forma entera
var diasAtraso = Int(diferenciaSegundos / segundosPorDia)

// Si la resta da negativa (entregó a tiempo), lo dejamos en 0
if diasAtraso < 0 {
    diasAtraso = 0
}

print("\n--- DETALLE DE MORA ---")
if diasAtraso > 0 {
    var dia = 1
    while dia <= diasAtraso {
        var tarifaDia = 0.0
        
        if dia == 1 {
            tarifaDia = 0.0
        } else if dia <= 3 {
            tarifaDia = tarifaBase
        } else if dia <= 6 {
            tarifaDia = tarifaBase * 1.50
        } else {
            tarifaDia = tarifaBase * 2.00
        }
        
        totalMulta += tarifaDia
        let fechaDia = cal.date(byAdding: .day, value: dia, to: fechaLimite)!
        print("Día \(dia) (\(formato.string(from: fechaDia))): S/ \(tarifaDia)")
        
        dia += 1 // Incrementa el día manualmente en cada vuelta
    }
} else {
    print("Sin mora registrada.")
}

// 5. EVALUACIÓN DE ESTADO Y SITUACIÓN
var estado = "Devuelto sin atraso"
if diasAtraso > 0 {
    estado = "Devuelto con atraso"
}

var situacion = "Habilitado"
if diasAtraso >= 10 {
    situacion = "Suspendido"
}

// 6. RESUMEN FINAL IMPRESO
print("\n================ RESUMEN ================")
print("Libro:             \(titulo)")
print("Usuario:           \(tipoNombre)")
print("-----------------------------------------")
print("Fecha Préstamo:    \(formato.string(from: fechaPrestamo))")
print("Fecha Límite:      \(formato.string(from: fechaLimite))")
print("Fecha Devolución:  \(formato.string(from: fechaDevolucion))")
print("-----------------------------------------")
print("Días de Atraso:    \(diasAtraso)")
print("Total a Pagar:     S/ \(totalMulta)")
print("Estado:            \(estado)")
print("Situación:         \(situacion)")
print("=========================================")