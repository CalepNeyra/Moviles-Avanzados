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

import Foundation

// ===== EJERCICIO 3: BUCLES FOR-IN =====

// --- Ejemplo (ya resuelto): ---
for i in 1...5 {
    print("Número: \(i)")
}

// --- TODO 7: Tabla de multiplicar del 7 ---
for i in 1...12 {
    print("7 x \(i) = \(7 * i)")
}

// --- TODO 8: Sumatoria del 1 al 100 ---
var suma = 0
for i in 1...100 {
    suma = suma + i
}
print("La suma del 1 al 100 es: \(suma)") // Debe dar 5050

// --- TODO 9: Calcular el factorial de 8 ---
var factorial = 1
for i in 1...8 {
    factorial = factorial * i
}
print("8! = \(factorial)") // Imprime 40320

// --- TODO 10: Patrón de asteriscos ---
for i in 1...5 {
    print(String(repeating: "*", count: i))
}


// ===== 3.2 – CORREGIR BUCLES =====

// FIX 4: El código original imprime impares porque evalúa '% 2 == 1'. 
// Corrección para imprimir pares del 2 al 20:
for i in 1...20 {
    if i % 2 == 0 {
        print(i)
    }
}

// FIX 5: El rango '1...10' cuenta hacia adelante (1 al 10). 
// Corrección para cuenta regresiva (10 al 1) usando stride o .reversed():
for i in stride(from: 10, through: 1, by: -1) {
    print(i)
}


// ===== 3.3 – PREDICCIONES =====

var total = 0
for i in 1...5 {
    total += i
}
print(total)
// PREDICT 6: Valor: 15 | ¿Cuántas iteraciones?: 5

var texto = ""
for _ in 1...3 {
    texto += "Hola "
}
print(texto)
// PREDICT 7: Imprime "Hola Hola Hola "
// ¿Para qué sirve _ en vez de i?: Se usa cuando no necesitas utilizar el valor de la variable de iteración dentro del bucle, evitando advertencias del compilador.

// Completado hasta aca

// ===== EJERCICIO 4: WHILE Y REPEAT-WHILE =====

// --- Ejemplo (ya resuelto): ---
var contador = 5
while contador > 0 {
    print("Cuenta regresiva: \(contador)")
    contador -= 1
}
print("¡Despegue!")


// --- TODO 11: Ahorro mensual ---
var ahorro = 0.0
var meses = 0
let meta = 2000.0
let ahorroMensual = 150.0

while ahorro < meta {
    ahorro += ahorroMensual
    meses += 1
}
print("Necesita \(meses) meses para juntar S/. \(meta)")


// --- TODO 12: División sucesiva ---
var numero = 1000.0
var divisiones = 0

while numero >= 1 {
    numero = numero / 2
    divisiones += 1
    print("División \(divisiones): \(numero)")
}
print("Se dividió \(divisiones) veces")


// ===== 4.2 – COMPLETAR REPEAT-WHILE =====

// --- TODO 13: Validar datos con repeat-while ---
let intento1 = 25
let intento2 = -3
let intento3 = 15

var intentoActual = intento1
var esValido = false
var numIntento = 1

repeat {
    if intentoActual >= 0 && intentoActual <= 20 {
        esValido = true
        print("Nota \(intentoActual) válida en intento \(numIntento)")
    } else {
        print("Nota \(intentoActual) inválida, intento \(numIntento)")
        if numIntento == 1 { intentoActual = intento2 }
        if numIntento == 2 { intentoActual = intento3 }
        numIntento += 1
    }
} while !esValido


// ===== 4.3 – PREDICCIONES =====

var a = 100
while a > 1 {
    a = a / 3
}
print(a)
// PREDICT 8: Valor final? 0 | ¿Cuántas vueltas? 5
// Pasos: 100 -> 33 (1a) -> 11 (2a) -> 3 (3a) -> 1 (4a) -> 0 (5a, detiene porque 0 no es > 1)

var b = 0
repeat {
    b += 1
} while b < 0
print(b)
// PREDICT 9: Valor? 1
// ¿Por qué repeat-while ejecuta al menos una vez?: Porque la condición de evaluación se encuentra al final del bloque (post-condición), ejecutando primero el cuerpo antes de verificar si debe repetir.