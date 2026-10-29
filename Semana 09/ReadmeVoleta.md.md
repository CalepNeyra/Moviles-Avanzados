# Guía Técnica: Sistema de Cálculo de Boleta de Pago Perú (iOS SwiftUI / Excel / Especificaciones Generales)

---

## 1. Parámetros Normativos y Reglas de Cálculo

### Parámetros Centralizados
- **Remuneración Mínima Vital (RMV):** S/ 1,230.00
- **Asignación Familiar:** 10% de la RMV (S/ 123.00), no se prorratea por días laborados.
- **Días del Mes Computable:** 30 días.
- **Jornada Diaria Computable:** 8 horas.
- **ONP:** 13% sobre el Total de Remuneraciones.
- **EsSalud (Aporte Empleador):** 9% sobre el Total de Remuneraciones.
- **Recargos por Horas Extras:** 
  - Primeras horas al 25%: Valor Hora × 1.25 × N° Horas
  - Horas subsiguientes al 35%: Valor Hora × 1.35 × N° Horas
- **AFP Ejemplo (Valores de Prueba):**
  - Fondo Obligatorio: 10.00%
  - Comisión Flujo: 1.60%
  - Seguro de Invalidez y Sobrevivencia: 1.35%
  - **Total Retención AFP Ejemplo:** 12.95%

### Convenciones Matemáticas
1. **Redondeo:** Cada concepto individual se redondea a 2 decimales usando la función de redondeo estándar (`REDONDEAR` en Excel o `round()` en Swift) antes de ser sumado o restado.
2. **Base Imponible:** Tanto la ONP como la AFP y EsSalud se calculan sobre el **Total de Remuneraciones** (Sueldo computable + Asignación Familiar + Horas Extras).
3. **Manejo de Conceptos Inactivos:** Todos los rubros no aplicables deben reflejar estrictamente `0.00` en la visualización final de la boleta.

---

## 2. Matriz de Casos de Prueba Oficiales

| Variable / Concepto | Caso 1 | Caso 2 | Caso 3 | Caso 4 | Oferta A | Oferta B |
| --- | --- | --- | --- | --- | --- | --- |
| Referencia | ONP, 30 días | ONP, 27 días | AFP + extras | Evaluación | Sueldo publicado | Sueldo publicado |
| **Sueldo Básico** | S/ 2,500.00 | S/ 1,800.00 | S/ 3,000.00 | S/ 4,200.00 | S/ 2,300.00 | S/ 3,000.00 |
| **Días Laborados** | 30 | 27 | 30 | 24 | 30 | 30 |
| **¿Tiene Hijos?** | No | Sí | Sí | Sí | No | No |
| **Sistema de Pensiones** | ONP | ONP | AFP | AFP | AFP | AFP |
| **Horas Extras 25%** | 0 | 0 | 4 | 2 | 0 | 0 |
| **Horas Extras 35%** | 0 | 0 | 4 | 2 | 0 | 0 |
| **Adelantos** | S/ 0.00 | S/ 0.00 | S/ 200.00 | S/ 100.00 | S/ 0.00 | S/ 0.00 |
| **Sueldo Computable** | S/ 2,500.00 | S/ 1,620.00 | S/ 3,000.00 | S/ 3,360.00 | S/ 2,300.00 | S/ 3,000.00 |
| **Asignación Familiar** | S/ 0.00 | S/ 123.00 | S/ 123.00 | S/ 123.00 | S/ 0.00 | S/ 0.00 |
| **Horas Extras 25% (Monto)** | S/ 0.00 | S/ 0.00 | S/ 62.50 | S/ 43.75 | S/ 0.00 | S/ 0.00 |
| **Horas Extras 35% (Monto)** | S/ 0.00 | S/ 0.00 | S/ 67.50 | S/ 47.25 | S/ 0.00 | S/ 0.00 |
| **TOTAL REMUNERACIONES** | **S/ 2,500.00** | **S/ 1,743.00** | **S/ 3,253.00** | **S/ 3,574.00** | **S/ 2,300.00** | **S/ 3,000.00** |
| **ONP (13%)** | S/ 325.00 | S/ 226.59 | S/ 0.00 | S/ 0.00 | S/ 0.00 | S/ 0.00 |
| **AFP Fondo (10%)** | S/ 0.00 | S/ 0.00 | S/ 325.30 | S/ 357.40 | S/ 230.00 | S/ 300.00 |
| **AFP Comisión** | S/ 0.00 | S/ 0.00 | S/ 52.05 | S/ 57.18 | S/ 36.80 | S/ 48.00 |
| **AFP Seguro** | S/ 0.00 | S/ 0.00 | S/ 43.92 | S/ 48.25 | S/ 31.51 | S/ 41.10 |
| **Adelantos** | S/ 0.00 | S/ 0.00 | S/ 200.00 | S/ 100.00 | S/ 0.00 | S/ 0.00 |
| **TOTAL DESCUENTOS** | **S/ 325.00** | **S/ 226.59** | **S/ 621.27** | **S/ 562.83** | **S/ 298.31** | **S/ 389.10** |
| **NETO A PAGAR** | **S/ 2,175.00** | **S/ 1,516.41** | **S/ 2,631.73** | **S/ 3,011.17** | **S/ 2,001.69** | **S/ 2,610.90** |
| **EsSalud (Empleador 9%)** | S/ 225.00 | S/ 156.87 | S/ 292.77 | S/ 321.66 | S/ 207.00 | S/ 270.00 |

---

## 3. Arquitectura e Interfaz en iOS (SwiftUI)

### Arquitectura de Archivos
* **`BoletaPagoAppIOSApp.swift`**: Punto de entrada principal de la aplicación.
* **`BoletaModel.swift`**: Modelo matemático estructurado con enumeraciones (`TipoPension`, `TipoAFP`) y redondeo estricto por concepto.
* **`ContentView.swift`**: Interfaz de usuario interactiva sincronizada en tiempo real.

### B. Evidencias Visuales de la App en Ejecución

* **1. Pantalla Principal y Carga de Parámetros:**
  > *(Inserta aquí tu captura de pantalla de la app corriendo en el simulador o dispositivo físico mostrando el ingreso de datos)*
  > `![App Principal](./evidencias/app_ejecucion_1.png)`

* **2. Despliegue de Resultados y Bloques Corporativos:**
  > *(Inserta aquí tu captura mostrando el desglose de remuneraciones, descuentos, EsSalud y el Neto a Pagar)*
  > `![Resultados Boleta](./evidencias/app_ejecucion_2.png)`

---

## 4. Estructura Requerida para el Archivo Excel (4 Hojas)

### Hoja 1: `Parámetros`
Almacena todas las constantes del sistema.
- Celdas con las tasas: RMV (`1230.00`), Asignación Familiar (`10%`), ONP (`13%`), EsSalud (`9%`), Horas Extras 25% (`1.25`), Horas Extras 35% (`1.35`).
- Tabla de Tasas AFP: Fondo (`10%`), Comisión (`1.60%`), Seguro (`1.35%`).

### Hoja 2: `Boleta`
Módulo de cálculo dinámico con tres bloques tabulares (Remuneraciones, Retenciones/Descuentos, Aportaciones Empleador) y el Neto a Pagar destacado. Debe usar exclusivamente referencias a la hoja de Parámetros y funciones `=REDONDEAR(..., 2)`.

### Hoja 3: `Casos`
Cuadro comparativo automatizado que calcula simultáneamente los 4 casos oficiales de la guía más los dos casos propios (Oferta A y Oferta B) basados en ofertas laborales reales.

### Hoja 4: `Explicación`
Resumen conceptual para usuarios sin experiencia contable, describiendo en lenguaje sencillo cómo se calcula cada rubro y acompañándolos de un ejemplo numérico paso a paso.
