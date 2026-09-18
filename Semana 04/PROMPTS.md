# Prompts utilizados — Laboratorio 04
 
## Herramienta de IA utilizada
Gemini / ChatGPT
 
## Caso 2B — Biblioteca
 
### Prompt 1:
"Implementa en Swift un sistema de gestión de biblioteca según:
1. Enum EstadoLibro (disponible, prestado).
2. Struct Libro (titulo, autor, estado).
3. Clase Biblioteca con arreglo de libros y métodos para agregar, prestar, devolver e inventario.
4. Utiliza guard statements, firstIndex y rawValues.
5. Agrega una simulación que ejecute las operaciones principales."
 
### Respuesta de la IA:
Generó la estructura de la biblioteca utilizando métodos funcionales (`firstIndex`, `.forEach`), manejo de guardas (`guard let`) para validaciones sin anidamiento y la extensión de `EstadoLibro` con `String` para simplificar la impresión del inventario.
 
### ¿Funcionó a la primera?
Sí, generó la lógica completa compilable y la simulación ejecutó sin errores mostrando los mensajes de validación esperados.
 
### ¿Usó algo que no hemos visto en clase?
Sí, utilizó `@discardableResult` en las funciones que retornaban booleanos para evitar advertencias en consola si no se asignaba el valor de retorno, y `private(set)` para encapsular el arreglo de libros.
 
## Mi versión (Parte A) vs. la versión de la IA (Parte B)
 
### ¿Qué hizo distinto la IA respecto a mi solución?
La IA reemplazó los bucles `for` tradicionales e índices manuales por `firstIndex(where:)` y `forEach`. Además, utilizó `guard let` para realizar salidas tempranas (*early returns*) en lugar de bloques `if/else` anidados.
 
### ¿Hay alguna línea de la IA que no entiendo del todo? ¿Cuál?
La anotación `@discardableResult` antes de `func prestar(...)`, la cual le indica al compilador de Swift que ignore la advertencia si llamamos al método sin guardar o evaluar su resultado booleano.
 
### ¿Qué me pareció mejor de MI versión?
Mi versión es más explícita y directa de seguir paso a paso al usar `for i in 0..<libros.count` y `switch`, lo cual facilita la depuración básica sin depender de clausuras o funciones de alto orden.
 
### ¿Qué me pareció mejor de la versión de la IA?
La legibilidad del código al evitar el anidamiento profundo gracias a `guard`, y la simplicidad al imprimir el inventario mediante el `RawValue` del enum (`libro.estado.rawValue`).

### Correccions