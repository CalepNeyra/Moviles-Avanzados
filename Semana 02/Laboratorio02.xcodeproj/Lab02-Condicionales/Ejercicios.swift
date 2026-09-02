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

// ===== EJERCICIO 5: CARRITO DE COMPRAS =====

// --- 5.1 Datos de productos ---
let prod1 = "Laptop"
let precio1 = 3500.0
let cant1 = 1

let prod2 = "Mouse"
let precio2 = 45.50
let cant2 = 2

let prod3 = "Teclado"
let precio3 = 120.00
let cant3 = 1

let prod4 = "Monitor"
let precio4 = 890.00
let cant4 = 1

let prod5 = "USB Cable"
let precio5 = 15.00
let cant5 = 3


// --- 5.2 Calcular subtotales ---
// TODO 14: Calcula el subtotal de cada producto
let sub1 = precio1 * Double(cant1)
let sub2 = precio2 * Double(cant2)
let sub3 = precio3 * Double(cant3)
let sub4 = precio4 * Double(cant4)
let sub5 = precio5 * Double(cant5)

// TODO 15: Calcula el subtotal general
let subtotalGeneral = sub1 + sub2 + sub3 + sub4 + sub5


// --- 5.3 Aplicar descuentos con if/else ---
// TODO 16: Aplica descuento según monto de compra
var porcentajeDescuento = 0.0
if subtotalGeneral >= 5000.0 {
    porcentajeDescuento = 0.15
} else if subtotalGeneral >= 2000.0 {
    porcentajeDescuento = 0.10
} else if subtotalGeneral >= 500.0 {
    porcentajeDescuento = 0.05
} else {
    porcentajeDescuento = 0.0
}

let descuento = subtotalGeneral * porcentajeDescuento
let subtotalConDescuento = subtotalGeneral - descuento


// --- 5.4 Categorizar cliente con switch ---
// TODO 17: Categoría de cliente según monto
let montoParaCategoria = Int(subtotalGeneral)
var categoriaCliente = ""

switch montoParaCategoria {
case 0..<500:
    categoriaCliente = "Regular"
case 500..<2000:
    categoriaCliente = "Frecuente"
case 2000..<5000:
    categoriaCliente = "VIP"
default:
    categoriaCliente = "Premium"
}


// --- 5.5 Calcular IGV y total ---
// TODO 18: Calcula IGV y total
let igv = subtotalConDescuento * 0.18
let totalFinal = subtotalConDescuento + igv


// --- 5.6 Imprimir ticket con bucle ---
// TODO 19: Imprime el ticket de compra
var separador = ""
for _ in 1...40 {
    separador += "="
}

print(separador)
print("        TICKET DE COMPRA")
print("  Cliente: \(categoriaCliente)")
print(separador)
print("\(prod1) x\(cant1)      S/. \(sub1)")
print("\(prod2) x\(cant2)       S/. \(sub2)")
print("\(prod3) x\(cant3)     S/. \(sub3)")
print("\(prod4) x\(cant4)     S/. \(sub4)")
print("\(prod5) x\(cant5)   S/. \(sub5)")
print(separador)
print("Subtotal:          S/. \(subtotalGeneral)")
print("Descuento (\(Int(porcentajeDescuento * 100))%): -S/. \(descuento)")
print("Subtotal c/desc:   S/. \(subtotalConDescuento)")
print("IGV (18%):         S/. \(igv)")
print(separador)
print("TOTAL:             S/. \(totalFinal)")
print(separador)
print("¡Gracias por su compra!")

// ===== EJERCICIO 6: CARRITO MEJORADO — CON IA =====

// --- Datos del carrito ---
// Nombre comercial asignado al primer producto del inventario
let producto1 = "Laptop"
// Precio unitario fijado en moneda local para el primer producto
let precioBase1 = 3500.0
// Unidades seleccionadas por el cliente para el primer producto
let cantidad1 = 1

// Nombre comercial asignado al segundo producto del inventario
let producto2 = "Mouse"
// Precio unitario fijado en moneda local para el segundo producto
let precioBase2 = 45.50
// Unidades seleccionadas por el cliente para el segundo producto (aplica descuento por cantidad)
let cantidad2 = 3

// Nombre comercial asignado al tercer producto del inventario
let producto3 = "Teclado"
// Precio unitario fijado en moneda local para el tercer producto
let precioBase3 = 120.00
// Unidades seleccionadas por el cliente para el tercer producto
let cantidad3 = 1

// Código de cupón promocional ingresado por el usuario en la interfaz
let cuponIngresado = "DESCUENTO20"


// --- 16. Validación de Precios y Cantidades ---
// Evalúa si algún precio unitario es menor o igual a cero o si alguna cantidad es menor o igual a cero
if precioBase1 <= 0 || precioBase2 <= 0 || precioBase3 <= 0 || cantidad1 <= 0 || cantidad2 <= 0 || cantidad3 <= 0 {
    // Emite una alerta de error en consola indicando inconsistencia en los datos del pedido
    print("ERROR: Todos los precios deben ser positivos y las cantidades mayores a 0.")
} else {

    // --- 12. Descuento por cantidad (5% extra si compra 3 o más unidades) ---
    // Determina si la cantidad del producto 1 califica para el descuento por volumen
    let aplicaDescCant1 = cantidad1 >= 3
    // Calcula la tasa de descuento individual aplicable al producto 1 (5% si califica, 0% si no)
    let tasaDescProd1 = aplicaDescCant1 ? 0.05 : 0.0
    // Multiplica el costo total bruto del producto 1 por el factor con descuento aplicado
    let subtotalProd1 = (precioBase1 * Double(cantidad1)) * (1.0 - tasaDescProd1)

    // Determina si la cantidad del producto 2 califica para el descuento por volumen
    let aplicaDescCant2 = cantidad2 >= 3
    // Calcula la tasa de descuento individual aplicable al producto 2 (5% si califica, 0% si no)
    let tasaDescProd2 = aplicaDescCant2 ? 0.05 : 0.0
    // Multiplica el costo total bruto del producto 2 por el factor con descuento aplicado
    let subtotalProd2 = (precioBase2 * Double(cantidad2)) * (1.0 - tasaDescProd2)

    // Determina si la cantidad del producto 3 califica para el descuento por volumen
    let aplicaDescCant3 = cantidad3 >= 3
    // Calcula la tasa de descuento individual aplicable al producto 3 (5% si califica, 0%vis si no)
    let tasaDescProd3 = aplicaDescCant3 ? 0.05 : 0.0
    // Multiplica el costo total bruto del producto 3 por el factor con descuento aplicado
    let subtotalProd3 = (precioBase3 * Double(cantidad3)) * (1.0 - tasaDescProd3)

    // Suma los subtotales netos calculados previamente para cada uno de los productos
    let subtotalBrutoArticulos = subtotalProd1 + subtotalProd2 + subtotalProd3


    // --- 13. Cupón de descuento (20% adicional si el código es "DESCUENTO20") ---
    // Verifica mediante una comparación estricta de cadenas si el cupón ingresado coincide con el código válido
    let esCuponValido = cuponIngresado == "DESCUENTO20"
    // Asigna un 20% (0.20) de descuento global si el cupón es válido, o 0.0 en caso contrario
    let porcentajeCupon = esCuponValido ? 0.20 : 0.0
    // Obtiene el monto exacto deducido multiplicando el subtotal acumulado por el porcentaje del cupón
    let montoMontoDescuentoCupon = subtotalBrutoArticulos * porcentajeCupon
    // Resta la deducción por cupón del subtotal bruto de artículos
    let subtotalConCupon = subtotalBrutoArticulos - montoMontoDescuentoCupon


    // --- 14. Envío Gratis (Gratis si supera S/. 3000, si no S/. 25.00) ---
    // Comprueba si el monto acumulado tras el cupón supera el umbral límite de 3000 soles
    let calificaEnvioGratis = subtotalConCupon > 3000.0
    // Asigna costo de envío nulo (0.0) si supera el umbral o la tarifa estándar (25.0) si no alcanza
    let costoEnvio = calificaEnvioGratis ? 0.0 : 25.0


    // --- Cálculo Final e IGV ---
    // Aplica el impuesto del 18% sobre la suma ajustada de los productos comprados
    let impuestoIGV = subtotalConCupon * 0.18
    // Agrega el valor del impuesto IGV y el costo de envío al subtotal neto obtenido
    let costoTotalPagar = subtotalConCupon + impuestoIGV + costoEnvio


    // --- 15. Puntos de fidelidad (1 punto por cada S/. 100 de compra) ---
    // Convierte el total a entero y realiza la división entre 100 para obtener la cantidad de puntos ganados
    let puntosFidelidadAcumulados = Int(costoTotalPagar) / 100


    // --- Impresión de Resultados ---
    // Muestra la cabecera de la sección de resultados en la consola
    print("===== TICKET CARRITO MEJORADO =====")
    // Imprime la línea del producto 1 especificando cantidad y costo calculado
    print("1. \(producto1) x\(cantidad1): S/. \(subtotalProd1)")
    // Imprime la línea del producto 2 especificando cantidad y costo calculado
    print("2. \(producto2) x\(cantidad2): S/. \(subtotalProd2)")
    // Imprime la línea del producto 3 especificando cantidad y costo calculado
    print("3. \(producto3) x\(cantidad3): S/. \(subtotalProd3)")
    // Muestra el subtotal previo a impuestos y cargos de entrega
    print("Subtotal de productos: S/. \(subtotalBrutoArticulos)")
    // Muestra el valor descontado por el cupón promocional
    print("Descuento por Cupón (\(cuponIngresado)): -S/. \(montoMontoDescuentoCupon)")
    // Muestra el monto correspondiente al impuesto de venta (IGV)
    print("IGV (18%): S/. \(impuestoIGV)")
    // Muestra la tarifa final de envío calculada
    print("Costo de Envío: S/. \(costoEnvio) \(calificaEnvioGratis ? "(¡Gratis!)" : "")")
    // Muestra la cifra total a saldar por la transacción completa
    print("TOTAL FINAL A PAGAR: S/. \(costoTotalPagar)")
    // Muestra el total de puntos de fidelidad acreditados al cliente en esta transacción
    print("Puntos de Fidelidad Ganados: \(puntosFidelidadAcumulados) pts")
    // Muestra el cierre decorativo de la sección del ticket
    print("====================================")
}

// ===== EJERCICIO 7: JUEGO DE ADIVINANZA — CON IA =====

// --- 17. Definición del número secreto ---
// Declara el número objetivo constante que el usuario intentará adivinar durante el juego
let numeroSecreto = 42

// --- 18. Simular 5 intentos con variables ---
// Declara el primer intento asignándole un valor entero simulado de prueba
let intento1 = 20
// Declara el segundo intento asignándole un valor entero simulado de prueba
let intento2 = 50
// Declara el tercer intento asignándole un valor entero simulado de prueba
let intento3 = 35
// Declara el cuarto intento asignándole un valor entero simulado de prueba
let intento4 = 42
// Declara el quinto intento asignándole un valor entero simulado de prueba
let intento5 = 10

// Almacena en un arreglo los intentos para poder iterar sobre ellos usando el bucle while
let listaIntentos = [intento1, intento2, intento3, intento4, intento5]

// Variable de control para iterar a través de los índices del arreglo listaIntentos
var indice = 0
// Contador que registrará el número de intentos realizados válidos
var intentosRealizados = 0
// Variable booleana que registrará si el jugador logró acertar el número secreto
var adivinoCorrectamente = false


// --- 19. Usar bucle while para recorrer los intentos ---
// Ejecuta el ciclo mientras queden intentos en el arreglo y el jugador no haya acertado aún
while indice < listaIntentos.count && !adivinoCorrectamente {
    
    // Extrae el valor numérico del intento actual de acuerdo a la posición del índice
    let intentoActual = listaIntentos[indice]
    // Incrementa en 1 la cantidad de intentos consumidos
    intentosRealizados += 1
    
    // Muestra en consola el número de intento actual y el valor ingresado
    print("Intento \(intentosRealizados): Probando con \(intentoActual)")
    
    // --- 20. Comparación de valores y respuesta del juego ---
    // Evalúa si el intento actual es exactamente igual al número secreto guardado
    if intentoActual == numeroSecreto {
        // Indica en consola que la respuesta ingresada es correcta
        print("-> ¡Correcto!")
        // Cambia el estado a verdadero para detener las iteraciones del bucle while
        adivinoCorrectamente = true
    // Evalúa si el número ingresado supera en valor al número secreto objetivo
    } else if intentoActual > numeroSecreto {
        // Notifica al usuario que su estimación está por encima del número objetivo
        print("-> Muy alto")
    // Se ejecuta si el número ingresado es estrictamente menor al número secreto
    } else {
        // Notifica al usuario que su estimación está por debajo del número objetivo
        print("-> Muy bajo")
    }
    
    // Incrementa el índice para pasar al siguiente intento en la próxima iteración del ciclo
    indice += 1
}


// --- 21 y 22. Evaluación del resultado final del juego ---
// Comprueba si el jugador adivinó con éxito antes de agotar la cantidad de intentos
if adivinoCorrectamente {
    // --- 21. Mostrar cuántos intentos necesitó ---
    // Imprime en pantalla el total de intentos utilizados para ganar el juego
    print("¡Felicidades! Adivinaste en \(intentosRealizados) intento(s).")
} else {
    // --- 22. Notificación de derrota si falló en los 5 intentos ---
    // Informa que el jugador perdió y revela cuál era el número secreto fijado
    print("Perdiste. El número era: \(numeroSecreto)")
}