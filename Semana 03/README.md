# 🚆 Sistema de Consulta y Gestión del Metro de Lima y Callao (L1 y L2)

![Swift](https://img.shields.io/badge/Swift-5.x-orange.svg)
![Environment](https://img.shields.io/badge/Environment-CLI_Terminal-black.svg)
![Institution](https://img.shields.io/badge/Tecsup-Programación_Móvil_Avanzada-blue.svg)

Sistema en consola desarrollado en Swift orientada a objetos y programación funcional para la simulación, planificación de rutas y verificación tarifaria de la red de transporte masivo del Metro de Lima y Callao.

---

## 👨‍💻 Información del Proyecto

* **Estudiante:** Calep Omar Neyra Taype
* **Curso:** Programación Móvil Avanzada
* **Docente:** Juan León
* **Institución:** Tecsup
* **Ubicación del código:** `Semana 03 / main.swift`

---

## 1. 🎯 Objetivo del Proyecto

El **Objetivo Principal** del proyecto es desarrollar una solución de consola (CLI) idiomática en Swift que permita la gestión, consulta e interacción centralizada con la red de infraestructura del Metro de Lima y Callao (Línea 1 y Línea 2). 

El sistema permite a los pasajeros y administradores:
1. **Consultar el estado operativo real** de la infraestructura (distinguiendo entre estaciones operativas como la Línea 1 completa y el Tramo 1A de la Línea 2, versus estaciones en construcción).
2. **Planificar rutas inteligentes** a partir de hitos urbanos, puntos de interés o nombres directos de estaciones.
3. **Calcular costos de pasaje y validar presupuestos** comparando el costo del viaje frente al saldo en tarjeta del usuario.
4. **Visualizar conexiones modales y accesibilidad universal** (elevadores, rampas y nodos de transbordo peatonal).

---

## 2. 📋 Requerimientos Funcionales

### **RF-01: Catálogo de Estaciones y Tarifas por Línea**
El sistema almacena la información completa de las estaciones de la **Línea 1** (26 estaciones) y **Línea 2** (27 estaciones).
* **Estructura tarifaria por línea:**
  * **Línea 1:** Pasaje Adulto S/ 1.50 | Medio Pasaje S/ 0.75
  * **Línea 2:** Pasaje Adulto S/ 1.40 | Medio Pasaje S/ 0.70
* **Atributos por estación:**
  * Nombre oficial e identificador correlativo (`[E-XX]`).
  * Posición ordinal dentro de la línea.
  * Ubicación exacta por cruce de avenidas.
  * Lista de puntos de interés y hitos urbanos cercanos.
  * Estado de operabilidad (`🟢 OPERATIVA` / `🔴 NO OPERATIVA`).
  * Indicador de accesibilidad adaptada para personas con discapacidad (`♿`).

### **RF-02: Consulta de Ficha Técnica con Costo**
* Permite la búsqueda de estaciones mediante coincidencia exacta o parcial de su nombre.
* Despliega una ficha técnica detallada que incluye la línea a la que pertenece, ubicación por cruce de avenidas, nivel de accesibilidad y el tarifario correspondiente.

### **RF-03: Planificador de Ruta ("¿Cómo llegar a un lugar?")**
* Permite búsquedas inversas introduciendo un destino o hito urbano (ej. *UNMSM, Mall del Sur, Hospital Almenara, Minka, Mercado Santa Anita*).
* Retorna la estación de descenso sugerida, el cruce de avenidas, el hito detectado y las tarifas aplicables (Adulto y Medio pasaje).

### **RF-04: Verificación de Presupuesto y Saldo en Tarjeta**
* Una vez seleccionada una ruta operativa, el sistema solicita al usuario ingresar el saldo disponible en su tarjeta en soles (S/).
* **Evaluación de viabilidad financiera:**
  * **Saldo suficiente:** Aprueba el abordaje y muestra el saldo restante en tarjeta.
  * **Saldo insuficiente:** Deniega el viaje, mostrando el pasaje requerido, el saldo actual y la diferencia exacta a recargar.
  * **Estación no operativa:** Emite una advertencia de restricción si la estación de destino se encuentra en fase de construcción u obras civiles.

### **RF-05: Módulo de Transbordos e Intercambios**
* Muestra los puntos oficiales de conexión entre líneas (ej. *Gamarra / Arriola ⇄ 28 de Julio E-16*).
* Detalla la modalidad de transferencia (ej. *Conexión Peatonal / Superficie*) y la referencia geográfica del punto de intercambio.

### **RF-06: Filtros de Red**
Permite filtrar dinámicamente la totalidad de estaciones bajo tres criterios:
1. Estaciones actualmente **OPERATIVAS (🟢)**.
2. Estaciones **EN CONSTRUCCIÓN / OBRAS (🔴)**.
3. Estaciones con **ACCESIBILIDAD GARANTIZADA (♿)**.

### **RF-07: Leyenda de Simbología Técnica**
Incluye un módulo informativo en el menú para explicar la nomenclatura y el código de colores ANSI utilizados en la interfaz de consola:
* `🟢 OPERATIVA`: En servicio comercial activo.
* `🔴 NO OPERATIVA`: En construcción / obras civiles.
* `[E-XX]`: Código de infraestructura oficial (Línea 2).
* `♿`: Infraestructura accesible.
* `🔗`: Punto de transbordo entre líneas.

---

## 3. ⚙️ Requerimientos No Funcionales

* **Arquitectura Swift Idiomática:** 
  * Modelado de datos inmutables mediante `struct` (`EstacionRed`, `LineaTransporte`, `TransbordoRed`).
  * Manejo estricto de estados mediante `enum` (`EstadoServicio`) con propiedades calculadas para las etiquetas y códigos de formato.
  * Uso intensivo de programación funcional (`flatMap`, `filter`, `first(where:)`) dentro de la clase administradora `GestorRedTransporte`.
* **Interfaz de Consola Enriquecida:** Implementación de extensiones sobre `String` para generar secuencias de escape ANSI (colores y estilos en terminal).
* **Validación Robusta de Entradas:** Manejo seguro de desempaquetado opcional e inducción de tipos (`Double`, `Int`) ante valores nulos o caracteres inválidos en la consola mediante `readLine()`.
* **Portabilidad:** Compatibilidad directa para su ejecución sin dependencias externas mediante el compilador estándar de Swift CLI.
* **Control de Versiones:** Historial de desarrollo registrado mediante commits descriptivos en Git.

---

## 🛠️ Estructura del Código Source (`main.swift`)

| Componente | Tipo | Descripción |
| :--- | :--- | :--- |
| `String (Extension)` | Extension | Extiende tipos nativos para formateo ANSI en terminal (negrita, colores). |
| `EstadoServicio` | `enum` | Representa la disponibilidad comercial de estaciones (`operativo`, `fueraDeServicio`). |
| `EstacionRed` | `struct` | Modelo entidad de cada estación de la red. |
| `LineaTransporte` | `struct` | Modelo entidad de cada línea del metro con tarifario y lista de paraderos. |
| `TransbordoRed` | `struct` | Estructura para registrar puntos de intercambio modal entre líneas. |
| `GestorRedTransporte` | `class` | Controlador central encargado de las consultas, planificador de rutas y filtros. |

---

## 🚀 Instrucciones de Ejecución

1. **Prerrequisitos:** Tener instalado el toolchain de Swift en macOS, Linux o mediante WSL.
2. **Clonar el repositorio:**
   ```bash
   git clone <URL_DE_TU_REPOSITTORIO>
   cd <NOMBRE_DEL_REPOSITORIO>