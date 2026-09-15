// Desarrollado por: Calep Omar Neyra Taype
import Foundation

// ===== TODO 8: Eliminar duplicados =====
var numeros: [Int] = []
print("===== INGRESO DE NÚMEROS =====")
for i in 1...8 {
    print("Número \(i):")
    let n = Int(readLine() ?? "") ?? 0
    numeros.append(n)
}

print("Con duplicados: \(numeros)")
let sinDuplicados = Array(Set(numeros)).sorted()
print("Sin duplicados: \(sinDuplicados)")

// ===== TODO 9: Comparar asistencia =====
var asistenciaLunes: Set<String> = []
var asistenciaMartes: Set<String> = []

print("\n===== ASISTENCIA LUNES =====")
for i in 1...4 {
    print("Alumno Lunes \(i):")
    let nombre = readLine() ?? ""
    asistenciaLunes.insert(nombre)
}

print("\n===== ASISTENCIA MARTES =====")
for i in 1...4 {
    print("Alumno Martes \(i):")
    let nombre = readLine() ?? ""
    asistenciaMartes.insert(nombre)
}

let ambosDias = asistenciaLunes.intersection(asistenciaMartes)
let soloLunes = asistenciaLunes.subtracting(asistenciaMartes)
let soloMartes = asistenciaMartes.subtracting(asistenciaLunes)

print("\n===== RESULTADOS DE ASISTENCIA =====")
print("Asistieron ambos días : \(ambosDias)")
print("Solo asistieron lunes : \(soloLunes)")
print("Solo asistieron martes: \(soloMartes)")