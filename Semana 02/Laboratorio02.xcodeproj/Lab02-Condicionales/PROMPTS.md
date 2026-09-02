# Prompts utilizados — Laboratorio 02

## Herramienta de IA utilizada
Gemini

## Ejercicio 6 — Carrito mejorado

### Prompt (estructura CTRFE):
**CONTEXTO:** Estoy desarrollando un proyecto en Swift sobre estructuras de control y condicionales.  
**TAREA:** Mejorar el carrito de compras agregando lógica de validación, descuento por cantidad, cupón promocional, envío gratis y puntos de fidelidad.  
**RESTRICCIONES:** Debe incluir validación para precios menores/iguales a 0 o cantidades menores/iguales a 0. Cada línea de código DEBE tener un comentario detallado explicando exactamente qué hace. Comentarios genéricos no son válidos.  
**FORMATO:** Código Swift listo para ejecutar en Playground o VS Code.  
**EJEMPLO:** `let aplicaDescCant1 = cantidad1 >= 3 // Evalúa si la cantidad califica para el descuento por volumen`

### ¿Funcionó a la primera?
Sí, el código cumplió con todas las condiciones impuestas y la inclusión de comentarios línea por línea.

### ¿La IA usó algo que no conocías?
Sí, el operador ternario `? :` para simplificar las condiciones en una sola línea.

---

## Ejercicio 7 — Juego de adivinanza

### Prompt (estructura CTRFE):
**CONTEXTO:** Estoy practicando bucles `while` y condicionales en Swift.  
**TAREA:** Crear un mini juego de adivinanza de números.  
**RESTRICCIONES:** Debe usar un número secreto fijo (42), simular 5 intentos con variables guardadas en un arreglo, recorrerlos mediante un bucle `while`, mostrar "Muy alto", "Muy bajo" o "¡Correcto!", e informar la victoria o derrota al finalizar los intentos. Se debe comentar CADA línea explicando la lógica de comparación.  
**FORMATO:** Código ejecutable en Swift.  
**EJEMPLO:** `while indice < listaIntentos.count && !adivinoCorrectamente { ... }`

### ¿Funcionó a la primera?
Sí, la estructura del bucle `while` con la bandera booleana detuvo las iteraciones correctamente al acertar el número.

### ¿La IA usó algo que no conocías?
La combinación de múltiples condiciones lógicas dentro del encabezado del `while` usando `&&` junto a variables de estado booleanas.