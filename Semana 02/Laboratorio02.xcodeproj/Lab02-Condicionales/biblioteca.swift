//
//  Biblioteca.swift
//  Laboratorio00
//

import Foundation

let formato = DateFormatter()
formato.dateFormat = "dd/MM/yyyy"

print("--- SISTEMA DE CONTROL DE BIBLIOTECA ---")

// 1. INGRESO DE TÍTULO
print("Ingrese el título del libro:")
let titulo = readLine() ?? "Libro General"

// 2. INGRESO DE TIPO DE USUARIO
print("Seleccione tipo de usuario (1: Alumno, 2: Docente, 3: Administrativo):")
let tipoEntrada = readLine() ?? "1"
let tipo = Int(tipoEntrada) ?? 1

// 3. INGRESO Y VALIDACIÓN DE FECHA DE PRÉSTAMO
var fechaPrestamo: Date? = nil
while fechaPrestamo == nil {
    print("Ingrese la Fecha de Préstamo (formato dd/MM/yyyy):")
    let texto = readLine() ?? ""
    fechaPrestamo = formato.date(from: texto)
    
    if fechaPrestamo == nil {
        print("❌ Fecha inválida. Intente de nuevo.\n")
    }
}

// 4. INGRESO Y VALIDACIÓN DE FECHA DE DEVOLUCIÓN
var fechaDevolucion: Date? = nil
while fechaDevolucion == nil {
    print("Ingrese la Fecha de Devolución (formato dd/MM/yyyy):")
    let texto = readLine() ?? ""
    fechaDevolucion = formato.date(from: texto)
    
    if fechaDevolucion == nil {
        print("❌ Fecha inválida. Intente de nuevo.\n")
    } else if fechaDevolucion! < fechaPrestamo! {
        print("❌ La devolución no puede ser antes del préstamo. Intente de nuevo.\n")
        fechaDevolucion = nil
    }
}

// 5. CONFIGURACIÓN SEGÚN TIPO DE USUARIO
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
} else if tipo == 4 {
    tarifaBase == 4.00
    tipoNombre = "Coordinador"
    diasPermitidos == 15
}

// 6. CÁLCULO DE FECHA LÍMITE Y DÍAS DE ATRASO
let segundosPorDia: TimeInterval = 86400
let fechaLimite = fechaPrestamo!.addingTimeInterval(segundosPorDia * Double(diasPermitidos))

let diferenciaSegundos = fechaDevolucion!.timeIntervalSince(fechaLimite)
var diasAtraso = Int(diferenciaSegundos / segundosPorDia)

if diasAtraso < 0 {
    diasAtraso = 0
}

// 7. TABLA DE MORA (Bucle while)
var totalMulta = 0.0

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

        if tipo == 4 {
            // Regla especial para Coordinador
            if dia <= 3 {
                tarifaDia = 0.0
            } else if dia <= 6 {
                tarifaDia = tarifaBase * 0.25 
            } else if dia <= 10 {
                tarifaDia = tarifaBase * 0.50  
            } else if dia <= 20 {
                tarifaDia = tarifaBase * 1.00
            } else {
                tarifaDia = tarifaBase * 1.00
            }
        }
        totalMulta += tarifaDia
        let fechaDia = fechaLimite.addingTimeInterval(segundosPorDia * Double(dia))
        print("Día \(dia) (\(formato.string(from: fechaDia))): S/ \(tarifaDia)")
        
        dia += 1
    }
} else {
    print("Sin mora registrada.")
}

// 8. ESTADO Y SITUACIÓN
var estado = "Devuelto sin atraso"
if diasAtraso > 0 {
    estado = "Devuelto con atraso"
}

var situacion = "Habilitado"
if diasAtraso >= 10 {
    situacion = "Suspendido"
}

// 9. RESUMEN FINAL
print("\n================ TARIFA DE COBRANZA DEL PRESTAMOS DE LIBROS ================")
print("Libro:             \(titulo)")
print("Usuario:           \(tipoNombre)")
print("-----------------------------------------")
print("Fecha Préstamo:    \(formato.string(from: fechaPrestamo!))")
print("Fecha Límite:      \(formato.string(from: fechaLimite))")
print("Fecha Devolución:  \(formato.string(from: fechaDevolucion!))")
print("-----------------------------------------")
print("Días de Atraso:    \(diasAtraso)")
print("Total a Pagar:     S/ \(totalMulta)")
print("Estado:            \(estado)")
print("Situación:         \(situacion)")
print("=========================================")