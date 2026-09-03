// Desarrollado por: Juan Leon
// Ejercicio 2: Diccionarios
import Foundation

print("=============================================")
print("          PARTE 1: EJEMPLO RESUELTO          ")
print("=============================================\n")

var contactos: [String: String] = [:]

for i in 1...3 {
    print("Contacto \(i) - Nombre:")
    let nombre = readLine() ?? ""
    print("Teléfono:")
    let telefono = readLine() ?? ""
    contactos[nombre] = telefono
}

print("\n===== DIRECTORIO =====")
for (nombre, telefono) in contactos {
    print("\(nombre): \(telefono)")
}

print("\nBuscar contacto:")
let buscar = readLine() ?? ""
if let tel = contactos[buscar] {
    print("Teléfono de \(buscar): \(tel)\n")
} else {
    print("\(buscar) no encontrado\n")
}


print("=============================================")
print("            PARTE 2: COMPLETAR TODO          ")
print("=============================================\n")

// ===== TODO 4: Catálogo de productos =====
var productos: [String: Double] = [:]

for i in 1...4 {
    print("Producto \(i) - Nombre:")
    let nombre = readLine() ?? ""
    print("Precio:")
    let precio = Double(readLine() ?? "") ?? 0
    productos[nombre] = precio
}

// ===== TODO 5: Mostrar catálogo =====
print("\n===== CATÁLOGO =====")
for (nombre, precio) in productos {
    print("\(nombre): S/. \(precio)")
}

// ===== TODO 6: Valor total =====
var valorTotal = 0.0
for (_, precio) in productos {
    valorTotal += precio
}
print("\nValor total: S/. \(valorTotal)\n")

// ===== TODO 7: Buscar producto =====
print("Buscar producto:")
let buscarProd = readLine() ?? ""
if let precioEncontrado = productos[buscarProd] {
    print("\(buscarProd) cuesta S/. \(precioEncontrado)\n")
} else {
    print("Producto no encontrado\n")
}


print("=============================================")
print("              PARTE 3: ANALYZE               ")
print("=============================================\n")

// ANALYZE 1: 
// ¿Qué hace? Recorre el diccionario 'edades', evalúa si cada edad es mayor o igual a 21, 
// y si cumple la condición, añade el nombre del contacto al array 'mayores'.
// ¿Qué imprime? Imprime: Mayores de 21: ["Luis"]

var edades: [String: Int] = ["Ana": 20, "Luis": 22, "María": 19]
var mayores: [String] = []

for (nombre, edad) in edades {
    if edad >= 21 {
        mayores.append(nombre)
    }
}

print("Mayores de 21: \(mayores)")