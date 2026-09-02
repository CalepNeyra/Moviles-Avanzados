import Foundation
// Docente : Juan León S.

// ===== EJERCICIO 1: CONDICIONALES =====

// --- Ejemplo (ya resuelto): ---
let nota = 15.0
if nota >= 13.0 {
    print("Aprobado con \(nota)")
} else {
    print("Desaprobado con \(nota)")
}

// --- TODO 1: Validar si una persona es mayor de edad ---
let edad = 17
if edad >= 18 {
    print("Es mayor de edad")
} else {
    print("Es menor de edad")
}

// --- TODO 2: Clasificar una nota con else if ---
let miNota = 16.0
// Categorías: Excelente (18-20), Bueno (15-17),
//            Aprobado (13-14), Desaprobado (0-12)
if miNota >= 18 {
    print("Excelente")
} else if miNota >= 15 {
    print("Bueno")
} else if miNota >= 13 {
    print("Aprobado")
} else {
    print("Desaprobado")
}

// --- TODO 3: Verificar si un número es positivo, negativo o cero ---
let numero = -5
if numero > 0 {
    print("El número es positivo")
} else if numero < 0 {
    print("El número es negativo")
} else {
    print("El número es cero")
}

// ===== 1.2 – CORREGIR ERRORES =====

// Error 1: Falta la llave de apertura '{' en 'else if'
let temperatura = 35
if temperatura > 30 {
    print("Hace calor")
} else if temperatura > 20 { // Se corrigió agregando '{'
    print("Clima agradable")
} else {
    print("Hace frío")
}

// Error 2: Operador de comparación incorrecto (saldo > compra no contempla exactitud/falta)
// y el cálculo del saldo faltante debe ser (compra - saldo) para no dar valor negativo
let saldo = 100.0
let compra = 150.0
if saldo >= compra { // Se corrigió a '>='
    print("Compra realizada")
} else {
    print("Saldo insuficiente: te faltan \(compra - saldo)") // Se invirtió la resta
}

// Error 3: 'hora = 25' sobrepasa el límite válido pero el control del 'else' lo gestiona correctamente.
// El error syntax/lógico está en la validación de límites o en el uso correcto de variables/rangos.
let hora = 25
if hora >= 0 && hora < 12 {
    print("Buenos días")
} else if hora >= 12 && hora < 18 {
    print("Buenas tardes")
} else if hora >= 18 && hora <= 23 {
    print("Buenas noches")
} else {
    print("Hora inválida")
}


// ===== 1.3 – PREDICCIONES =====

let x = 10
if x > 5 && x < 20 {
    print("Dentro del rango")
} else {
    print("Fuera del rango")
}
// PREDICT 1: Imprime "Dentro del rango"

let y = 15
if y > 20 {
    print("Mayor que 20")
} else if y > 10 {
    print("Mayor que 10")
} else if y > 5 {
    print("Mayor que 5")
}
// PREDICT 2: Imprime "Mayor que 10"
// ¿Por qué no imprime "Mayor que 5" también?: Porque la estructura 'if / else if' se evalúa en cadena y se detiene en la primera condición que resulte verdadera (y > 10).

let esLunes = true
let llueve = false
if esLunes && llueve {
    print("Lunes lluvioso")
} else if esLunes || llueve {
    print("Es lunes O llueve")
} else {
    print("Ni lunes ni llueve")
}
// PREDICT 3: Imprime "Es lunes O llueve" va salir que es "Es lunes O llueve"

// ===== EJERCICIO 2: SWITCH =====

// --- Ejemplo (ya resuelto): ---
let diaSemana = 3
switch diaSemana {
case 1: print("Lunes")
case 2: print("Martes")
case 3: print("Miércoles")
case 4: print("Jueves")
case 5: print("Viernes")
case 6: print("Sábado")
case 7: print("Domingo")
default: print("Día inválido")
}

// --- TODO 4: Clasificar nota numérica a letra ---
let nota = 16
switch nota {
case 18...20: print("Excelente (A)")
case 15...17: print("Bueno (B)")
case 13...14: print("Aprobado (C)")
case 11...12: print("En Recuperación (D)")
case 0...10: print("Desaprobado (F)")
default: print("Nota inválida")
}

// --- TODO 5: Calculadora simple con switch ---
let num1 = 20.0
let num2 = 5.0
let operacion = "+"

switch operacion {
case "+": print("Resultado: \(num1 + num2)")
case "-": print("Resultado: \(num1 - num2)")
case "*": print("Resultado: \(num1 * num2)")
case "/":
    if num2 != 0 {
        print("Resultado: \(num1 / num2)")
    } else {
        print("Error: No se puede dividir entre cero")
    }
default: print("Operación no válida")
}

// --- TODO 6: Categoría de producto por precio ---
let precio = 350.0

switch precio {
case 0..<100: print("Económico")
case 100..<500: print("Medio")
case 500..<1000: print("Premium")
case 1000...: print("Lujo")
default: print("Precio inválido")
}


// ===== 2.2 – PREDICCIONES =====

let mes = 2
switch mes {
case 1, 3, 5, 7, 8, 10, 12: print("31 días")
case 4, 6, 9, 11: print("30 días")
case 2: print("28 o 29 días")
default: print("Mes inválido")
}
// PREDICT 4: Imprime "28 o 29 días"

let letra: Character = "a"
switch letra {
case "a", "e", "i", "o", "u": print("Vocal")
default: print("Consonante")
}
// PREDICT 5: Imprime "Vocal"