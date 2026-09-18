# Registro de Prompts - Caso 2 Parte B (Biblioteca CON IA)

## Prompt Utilizado

> "Implementa en Swift un sistema de gestión de biblioteca de acuerdo a las siguientes especificaciones:
> 1. Un enum `EstadoLibro` con casos `disponible` y `prestado`.
> 2. Un struct `Libro` con `titulo`, `autor` y `estado`.
> 3. Una clase `Biblioteca` con un arreglo de libros y métodos para:
>    - `agregar(libro: Libro)`
>    - `prestar(titulo: String) -> Bool`
>    - `devolver(titulo: String) -> Bool`
>    - `inventario()` que imprima los libros con su formato `Titulo (Autor) - estado`.
> 4. Utiliza buenas prácticas idiomáticas de Swift (guard statements, firstIndex, rawValues) evitando bucles `for` tradicionales o variables auxiliares innecesarias.
> 5. Agrega una simulación que valide préstamos repetidos, devoluciones e intentos sobre libros inexistentes."

## Comparación: Manual (Parte A) vs IA (Parte B)

| Criterio | Solución Manual (Parte A) | Solución IA (Parte B) |
| :--- | :--- | :--- |
| **Búsqueda** | Bucle `for i in 0..<libros.count` | `firstIndex(where:)` |
| **Manejo de Errores** | Sentencias `if/else` anidadas | `guard let` con early return |
| **Enum Estado** | Enum simple con `switch` en inventario | Enum con `RawValue: String` |
| **Impresión Inventario** | Bucle `for-in` iterativo | `.forEach` funcional |