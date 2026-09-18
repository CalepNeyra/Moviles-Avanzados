// ===== CASO 2 — PARTE B: BIBLIOTECA (CON IA) =====
// Docente: Juan León

import Foundation

// 1. Enum con Raw Value para representación textual directa
enum EstadoLibro: String {
    case disponible = "disponible"
    case prestado = "prestado"
}

// 2. Struct Libro
struct Libro {
    let titulo: String
    let autor: String
    var estado: EstadoLibro = .disponible
}

// 3. Class Biblioteca (Enfoque idiomatico en Swift usando Programación Funcional)
class Biblioteca {
    private(set) var libros: [Libro] = []
    
    func agregar(libro: Libro) {
        libros.append(libro)
    }
    
    @discardableResult
    func prestar(titulo: String) -> Bool {
        guard let index = libros.firstIndex(where: { $0.titulo == titulo }) else {
            print("Error: no existe \(titulo)")
            return false
        }
        
        guard libros[index].estado == .disponible else {
            print("Error: \(titulo) ya está prestado")
            return false
        }
        
        libros[index].estado = .prestado
        print("Préstamo aprobado: \(titulo)")
        return true
    }
    
    @discardableResult
    func devolver(titulo: String) -> Bool {
        guard let index = libros.firstIndex(where: { $0.titulo == titulo }) else {
            print("Error: no existe \(titulo)")
            return false
        }
        
        guard libros[index].estado == .prestado else {
            print("Error: \(titulo) no está prestado")
            return false
        }
        
        libros[index].estado = .disponible
        print("Devolución registrada: \(titulo)")
        return true
    }
    
    func inventario() {
        print("===== INVENTARIO =====")
        libros.forEach { libro in
            print("\(libro.titulo) (\(libro.autor)) - \(libro.estado.rawValue)")
        }
    }
}

// 4. Simulación
let miBiblioteca = Biblioteca()

miBiblioteca.agregar(libro: Libro(titulo: "Cien años de soledad", autor: "Gabriel García Márquez"))
miBiblioteca.agregar(libro: Libro(titulo: "La ciudad y los perros", autor: "Mario Vargas Llosa"))
miBiblioteca.agregar(libro: Libro(titulo: "El Quijote", autor: "Miguel de Cervantes"))

miBiblioteca.prestar(titulo: "La ciudad y los perros")
miBiblioteca.prestar(titulo: "La ciudad y los perros")
miBiblioteca.devolver(titulo: "La ciudad y los perros")
miBiblioteca.prestar(titulo: "El Quijote")
miBiblioteca.prestar(titulo: "El Principito")

miBiblioteca.inventario()