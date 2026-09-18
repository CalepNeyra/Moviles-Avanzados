// ===== CASO 2 — PARTE A: BIBLIOTECA (SIN IA) =====
// Docente: Juan León

// 1. enum EstadoLibro
enum EstadoLibro {
    case disponible
    case prestado
}
// 2. struct Libro
struct Libro {
    let titulo: String
    let autor: String
    var estado: EstadoLibro = .disponible
}
// 3. class Biblioteca
class Biblioteca {
    var libros: [Libro] = []
    
    func agregar(libro: Libro) {
        libros.append(libro)
    }
    
    func prestar(titulo: String) -> Bool {
        for i in 0..<libros.count {
            if libros[i].titulo == titulo {
                if libros[i].estado == .disponible {
                    libros[i].estado = .prestado
                    print("Préstamo aprobado: \(titulo)")
                    return true
                } else {
                    print("Error: \(titulo) ya está prestado")
                    return false
                }
            }
        }
        print("Error: no existe \(titulo)")
        return false
    }
    
    func devolver(titulo: String) -> Bool {
        for i in 0..<libros.count {
            if libros[i].titulo == titulo {
                if libros[i].estado == .prestado {
                    libros[i].estado = .disponible
                    print("Devolución registrada: \(titulo)")
                    return true
                } else {
                    print("Error: \(titulo) no está prestado")
                    return false
                }
            }
        }
        print("Error: no existe \(titulo)")
        return false
    }
    
    func inventario() {
        print("===== INVENTARIO =====")
        for libro in libros {
            var estadoTexto = ""
            switch libro.estado {
            case .disponible:
                estadoTexto = "disponible"
            case .prestado:
                estadoTexto = "prestado"
            }
            print("\(libro.titulo) (\(libro.autor)) - \(estadoTexto)")
        }
    }
}
// 4. Simulación
let miBiblioteca = Biblioteca()

miBiblioteca.agregar(libro: Libro(titulo: "Cien años de soledad", autor: "Gabriel García Márquez"))
miBiblioteca.agregar(libro: Libro(titulo: "La ciudad y los perros", autor: "Mario Vargas Llosa"))
miBiblioteca.agregar(libro: Libro(titulo: "El Quijote", autor: "Miguel de Cervantes"))

_ = miBiblioteca.prestar(titulo: "La ciudad y los perros")
_ = miBiblioteca.prestar(titulo: "La ciudad y los perros")
_ = miBiblioteca.devolver(titulo: "La ciudad y los perros")
_ = miBiblioteca.prestar(titulo: "El Quijote")
_ = miBiblioteca.prestar(titulo: "El Principito")

miBiblioteca.inventario()