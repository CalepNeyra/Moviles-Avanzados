// Desarrollado por: [calep neyra taype]
// Ejercicio 1: Arrays
import Foundation

print("=============================================")
print("          PARTE 1: EJEMPLO RESUELTO          ")
print("=============================================\n")

// Crear un array vacío de notas
var notas: [Double] = []

// Pedir al usuario 3 notas
for i in 1...3 {
    print("Ingrese la nota \(i):")
    let entrada = readLine() ?? ""
    let nota = Double(entrada) ?? 0
    notas.append(nota)
}

// Mostrar las notas ingresadas
print("\nNotas ingresadas: \(notas)")
print("Total de notas: \(notas.count)")

// Calcular el promedio
var suma = 0.0
for nota in notas {
    suma += nota
}
let promedio = suma / Double(notas.count)

// Mostrar resultados
print("Suma: \(suma)")
print("Promedio: \(promedio)")
print("Nota más alta: \(notas.max()!)")
print("Nota más baja: \(notas.min()!)")
print("Notas ordenadas: \(notas.sorted())\n")


print("=============================================")
print("            PARTE 2: COMPLETAR TODO          ")
print("=============================================\n")

// ===== TODO 1: Registro de 5 alumnos =====
var alumnos: [String] = []
for i in 1...5 {
    print("Nombre del alumno \(i):")
    let nombre = readLine() ?? ""
    alumnos.append(nombre)
}
print("Alumnos: \(alumnos)\n")

// ===== TODO 2: Buscar un alumno =====
print("Buscar alumno:")
let buscar = readLine() ?? ""
if alumnos.contains(buscar) {
    print("\(buscar) está en la lista\n")
} else {
    print("\(buscar) NO está en la lista\n")
}

// ===== TODO 3: Notas con clasificación =====
var notasClase: [Double] = []
for i in 1...5 {
    print("Nota del alumno \(i):")
    let n = Double(readLine() ?? "") ?? 0
    notasClase.append(n)
}

var aprobados = 0
var desaprobados = 0
var sumaNotas = 0.0

for nota in notasClase {
    sumaNotas += nota
    if nota >= 13 {
        aprobados += 1
    } else {
        desaprobados += 1
    }
}

print("Promedio: \(sumaNotas / Double(notasClase.count))")
print("Aprobados: \(aprobados), Desaprobados: \(desaprobados)\n")


print("=============================================")
print("         PARTE 3: FIX (CORREGIDO)            ")
print("=============================================\n")

// FIX 1: Un array de Strings no acepta enteros. Se corrige cambiando 7 por un String.
var frutas = ["Manzana", "Plátano", "Naranja"]
frutas.append("Uva") 

// FIX 2: Para mutar o agregar elementos se requiere 'var', no 'let'.
var colores = ["Rojo", "Azul", "Verde"] 
colores.append("Amarillo")

// FIX 3: El índice 5 estaba fuera de rango (Index out of range).
let numeros = [10, 20, 30, 40, 50]
print("Número en índice 4: \(numeros[4])\n")


print("=============================================")
print("              PARTE 4: PREDICT               ")
print("=============================================\n")

// PREDICT 1: [2, 3, 4, 5, 6] -> remove(at: 0) borra el 1, append(6) añade 6 al final
// PREDICT 2: 5 -> Quedan 5 elementos
// PREDICT 3: ["Ana", "Beto", "Carlos"] -> Retorna nuevo array ordenado
// PREDICT 4: ["Ana", "Carlos", "Beto"] -> El array original no se modifica

var lista = [1, 2, 3, 4, 5]
lista.remove(at: 0)
lista.append(6)
print("PREDICT 1 (Lista modificada): \(lista)")
print("PREDICT 2 (Conteo): \(lista.count)")

var nombres = ["Ana", "Carlos", "Beto"]
print("PREDICT 3 (Ordenado): \(nombres.sorted())")
print("PREDICT 4 (Original): \(nombres)")