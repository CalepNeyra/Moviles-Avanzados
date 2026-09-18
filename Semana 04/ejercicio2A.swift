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