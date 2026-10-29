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
  - Primeras 2 horas (25%): $\text{Valor Hora} \times 1.25 \times \text{N° Horas}$
  - Horas subsiguientes (35%): $\text{Valor Hora} \times 1.35 \times \text{N° Horas}$
- **AFP Ejemplo (Valores de Prueba):**
  - Fondo Obligatorio: 10.00%
  - Comisión Flujo: 1.60%
  - Seguro de Invalidez y Sobrevivencia: 1.35%
  - **Total Retención AFP Ejemplo:** 12.95%

### Convenciones Matemáticas
1. **Redondeo:** Cada concepto individual se redondea a 2 decimales usando la función de redondeo estándar (`ROUND` en Excel o `round()` en Swift) antes de ser sumado o restado.
2. **Base Imponible:** Tanto la ONP como la AFP y EsSalud se calculan sobre el **Total de Remuneraciones** (Sueldo computable + Asignación Familiar + Horas Extras).
3. **Manejo de Conceptos Inactivos:** Todos los rubros no aplicables deben reflejar estrictamente `0.00` en la visualización final de la boleta.

---

## 2. Matriz de Casos de Prueba Oficiales

| Variable / Concepto | Caso 1 | Caso 2 | Caso 3 | Caso 4 (Evaluación) |
| :--- | :---: | :---: | :---: | :---: |
| **Sueldo Básico** | S/ 2,500.00 | S/ 1,800.00 | S/ 3,000.00 | S/ 4,200.00 |
| **Días Laborados** | 30 | 27 | 30 | 24 |
| **¿Tiene Hijos?** | No | Sí | Sí | Sí |
| **Sistema de Pensiones** | ONP (13%) | ONP (13%) | AFP (12.95%) | AFP (12.95%) |
| **Horas Extras 25%** | 0 | 0 | 4 | 2 |
| **Horas Extras 35%** | 0 | 0 | 4 | 2 |
| **Adelantos** | S/ 0.00 | S/ 0.00 | S/ 200.00 | S/ 100.00 |
| **Sueldo Computable** | S/ 2,500.00 | S/ 1,620.00 | S/ 3,000.00 | S/ 3,360.00 |
| **Asignación Familiar** | S/ 0.00 | S/ 123.00 | S/ 123.00 | S/ 123.00 |
| **Horas Extras 25% (Monto)**| S/ 0.00 | S/ 0.00 | S/ 62.50 | S/ 43.75 |
| **Horas Extras 35% (Monto)**| S/ 0.00 | S/ 0.00 | S/ 67.50 | S/ 47.25 |
| **TOTAL REMUNERACIONES** | **S/ 2,500.00** | **S/ 1,743.00** | **S/ 3,253.00** | **S/ 3,574.00** |
| **ONP (13%)** | S/ 325.00 | S/ 226.59 | S/ 0.00 | S/ 0.00 |
| **AFP Fondo (10%)** | S/ 0.00 | S/ 0.00 | S/ 325.30 | S/ 357.40 |
| **AFP Comisión (1.60%)** | S/ 0.00 | S/ 0.00 | S/ 52.05 | S/ 57.18 |
| **AFP Seguro (1.35%)** | S/ 0.00 | S/ 0.00 | S/ 43.92 | S/ 48.25 |
| **Adelantos** | S/ 0.00 | S/ 0.00 | S/ 200.00 | S/ 100.00 |
| **TOTAL DESCUENTOS** | **S/ 325.00** | **S/ 226.59** | **S/ 621.27** | **S/ 562.83** |
| **NETO A PAGAR** | **S/ 2,175.00** | **S/ 1,516.41** | **S/ 2,631.73** | **S/ 3,011.17** |
| **EsSalud (Empleador 9%)**| S/ 225.00 | S/ 156.87 | S/ 292.77 | S/ 321.66 |

---

## 3. Código Final en SwiftUI (iOS)

### Arquitectura de Archivos
- `BoletaModel.swift`: Lógica matemática y estructura de datos.
- `ContentView.swift`: Interfaz de usuario dinámica con ScrollView, controles validados e integración de bloques corporativos.

#### Archivo: `BoletaModel.swift`
```swift
import Foundation

struct BoletaCalculadora {
    // Parámetros normativos fijos
    let rmv: Double = 1230.00
    
    // Resultados de Remuneraciones
    var sueldoComputable: Double = 0.0
    var asignacionFamiliar: Double = 0.0
    var montoHE25: Double = 0.0
    var montoHE35: Double = 0.0
    var totalRemuneraciones: Double = 0.0
    
    // Resultados de Descuentos
    var montoONP: Double = 0.0
    var montoAFPFondo: Double = 0.0
    var montoAFPComision: Double = 0.0
    var montoAFPSeguro: Double = 0.0
    var montoAdelantos: Double = 0.0
    var totalDescuentos: Double = 0.0
    
    // Aportaciones del Empleador
    var esSaludEmpleador: Double = 0.0
    
    // Neto a Pagar
    var netoAPagar: Double = 0.0

    mutating func calcular(
        sueldoBasico: Double,
        diasLaborados: Int,
        tieneHijos: Bool,
        esONP: Bool,
        horas25: Double,
        horas35: Double,
        adelantos: Double
    ) {
        // 1. Sueldo computable (Sueldo / 30 * Días)
        let brutoDiario = sueldoBasico / 30.0
        sueldoComputable = round((brutoDiario * Double(diasLaborados)) * 100) / 100
        
        // 2. Asignación familiar
        asignacionFamiliar = tieneHijos ? round((rmv * 0.10) * 100) / 100 : 0.0
        
        // 3. Valor hora y Horas Extras
        let valorHora = (sueldoBasico / 30.0) / 8.0
        montoHE25 = round((valorHora * 1.25 * horas25) * 100) / 100
        montoHE35 = round((valorHora * 1.35 * horas35) * 100) / 100
        
        // Total Remuneraciones
        totalRemuneraciones = round((sueldoComputable + asignacionFamiliar + montoHE25 + montoHE35) * 100) / 100
        
        // 4. Retenciones y Descuentos
        if esONP {
            montoONP = round((totalRemuneraciones * 0.13) * 100) / 100
            montoAFPFondo = 0.0
            montoAFPComision = 0.0
            montoAFPSeguro = 0.0
        } else {
            montoONP = 0.0
            montoAFPFondo = round((totalRemuneraciones * 0.10) * 100) / 100
            montoAFPComision = round((totalRemuneraciones * 0.0160) * 100) / 100
            montoAFPSeguro = round((totalRemuneraciones * 0.0135) * 100) / 100
        }
        
        montoAdelantos = round(adelantos * 100) / 100
        
        let sumaDescuentos = montoONP + montoAFPFondo + montoAFPComision + montoAFPSeguro + montoAdelantos
        totalDescuentos = round(sumaDescuentos * 100) / 100
        
        // 5. Aportaciones del Empleador
        esSaludEmpleador = round((totalRemuneraciones * 0.09) * 100) / 100
        
        // 6. Neto a Pagar
        netoAPagar = round((totalRemuneraciones - totalDescuentos) * 100) / 100
    }
}
```

#### Archivo: `ContentView.swift`
```swift
import SwiftUI

struct ContentView: View {
    @State private var calculadora = BoletaCalculadora()
    
    @State private var casoSeleccionado: Int = 1
    
    @State private var sueldoBasicoInput: String = ""
    @State private var diasLaboradosInput: String = ""
    @State private var tieneHijosToggle: Bool = false
    @State private var sistemaPensiones: String = "ONP"
    @State private var afpSeleccionada: String = "AFP Ejemplo"
    @State private var horas25Input: String = ""
    @State private var horas35Input: String = ""
    @State private var adelantosInput: String = ""
    
    @State private var mostrado: Bool = false
    @State private var mostrarAlerta: Bool = false
    @State private var mensajeAlerta: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cálculo Laboral Perú")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Boleta de Pago")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cargar Caso de Prueba (Guía)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        Picker("Caso", selection: $casoSeleccionado) {
                            Text("Caso 1").tag(1)
                            Text("Caso 2").tag(2)
                            Text("Caso 3").tag(3)
                            Text("Caso 4").tag(4)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: casoSeleccionado) { nuevoCaso in
                            cargarDatosCaso(nuevoCaso)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Parámetros de Entrada")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        HStack {
                            Text("Sueldo básico (S/):")
                            Spacer()
                            TextField("Ej. 2500", text: $sueldoBasicoInput)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                        }
                        
                        HStack {
                            Text("Días laborados (1-30):")
                            Spacer()
                            TextField("Ej. 30", text: $diasLaboradosInput)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                        }
                        
                        Picker("¿Tiene hijos?", selection: $tieneHijosToggle) {
                            Text("No").tag(false)
                            Text("Sí").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Picker("Sistema de pensiones", selection: $sistemaPensiones) {
                            Text("ONP").tag("ONP")
                            Text("AFP").tag("AFP")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        if sistemaPensiones == "AFP" {
                            HStack {
                                Text("AFP seleccionada:")
                                Spacer()
                                Picker("AFP", selection: $afpSeleccionada) {
                                    Text("AFP Ejemplo").tag("AFP Ejemplo")
                                    Text("Habitat").tag("Habitat")
                                    Text("Integra").tag("Integra")
                                    Text("Prima").tag("Prima")
                                    Text("Profuturo").tag("Profuturo")
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            .transition(.opacity)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Horas extras 25%:")
                            Spacer()
                            TextField("Ej. 0", text: $horas25Input)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                        }
                        
                        HStack {
                            Text("Horas extras 35%:")
                            Spacer()
                            TextField("Ej. 0", text: $horas35Input)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                        }
                        
                        HStack {
                            Text("Adelantos (S/):")
                            Spacer()
                            TextField("Ej. 0.00", text: $adelantosInput)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                        }
                        
                        Button(action: {
                            guard let basico = Double(sueldoBasicoInput), basico > 0 else {
                                mensajeAlerta = "El sueldo básico debe ser mayor a cero."
                                mostrarAlerta = true
                                mostrado = false
                                return
                            }
                            
                            guard let dias = Int(diasLaboradosInput), dias >= 1, dias <= 30 else {
                                mensajeAlerta = "Los días laborados deben estar entre 1 y 30."
                                mostrarAlerta = true
                                mostrado = false
                                return
                            }
                            
                            let h25 = Double(horas25Input) ?? 0.0
                            let h35 = Double(horas35Input) ?? 0.0
                            let adelanto = Double(adelantosInput) ?? 0.0
                            
                            guard h25 >= 0, h35 >= 0, adelanto >= 0 else {
                                mensajeAlerta = "Las horas extras y adelantos no pueden ser negativos."
                                mostrarAlerta = true
                                mostrado = false
                                return
                            }
                            
                            let esONP = (sistemaPensiones == "ONP")
                            
                            calculadora.calcular(
                                sueldoBasico: basico,
                                diasLaborados: dias,
                                tieneHijos: tieneHijosToggle,
                                esONP: esONP,
                                horas25: h25,
                                horas35: h35,
                                adelantos: adelanto
                            )
                            mostrado = true
                        }) {
                            Text("Calcular Boleta")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.top, 5)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .alert(isPresented: $mostrarAlerta) {
                        Alert(title: Text("Validación de Datos"), message: Text(mensajeAlerta), dismissButton: .default(Text("OK")))
                    }
                    
                    if mostrado {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Resultado de la Boleta (Caso \(casoSeleccionado))")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            // Bloque 1: REMUNERACIONES
                            VStack(alignment: .leading, spacing: 8) {
                                Text("REMUNERACIONES").font(.subheadline).bold().foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(8)
                                    .background(Color.blue)
                                    .cornerRadius(6)
                                
                                FilaBoleta(concepto: "Sueldo computable", monto: calculadora.sueldoComputable)
                                FilaBoleta(concepto: "Asignación familiar", monto: calculadora.asignacionFamiliar)
                                FilaBoleta(concepto: "Horas extras 25%", monto: calculadora.montoHE25)
                                FilaBoleta(concepto: "Horas extras 35%", monto: calculadora.montoHE35)
                                Divider()
                                FilaBoleta(concepto: "Total remuneraciones", monto: calculadora.totalRemuneraciones, isBold: true)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(radius: 1)
                            
                            // Bloque 2: RETENCIONES / DESCUENTOS
                            VStack(alignment: .leading, spacing: 8) {
                                Text("RETENCIONES / DESCUENTOS").font(.subheadline).bold().foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(8)
                                    .background(Color.blue)
                                    .cornerRadius(6)
                                
                                FilaBoleta(concepto: "ONP", monto: calculadora.montoONP)
                                FilaBoleta(concepto: "AFP fondo", monto: calculadora.montoAFPFondo)
                                FilaBoleta(concepto: "AFP comisión", monto: calculadora.montoAFPComision)
                                FilaBoleta(concepto: "AFP seguro", monto: calculadora.montoAFPSeguro)
                                FilaBoleta(concepto: "Adelantos", monto: calculadora.montoAdelantos)
                                Divider()
                                FilaBoleta(concepto: "Total descuentos", monto: calculadora.totalDescuentos, isBold: true)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(radius: 1)
                            
                            // Bloque 3: APORTACIONES DEL EMPLEADOR
                            VStack(alignment: .leading, spacing: 8) {
                                Text("APORTACIONES DEL EMPLEADOR").font(.subheadline).bold().foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(8)
                                    .background(Color.blue)
                                    .cornerRadius(6)
                                
                                FilaBoleta(concepto: "EsSalud (9%)", monto: calculadora.esSaludEmpleador)
                                Divider()
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(radius: 1)
                            
                            HStack {
                                Text("NETO A PAGAR:")
                                    .font(.title3)
                                    .bold()
                                Spacer()
                                Text("S/ \(String(format: "%.2f", calculadora.netoAPagar))")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(10)
                            
                            Text("Los conceptos que no aplican se muestran con 0.00, como en la boleta real.")
                                .font(.caption2)
                                .italic()
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
        }
    }
    
    func cargarDatosCaso(_ caso: Int) {
        switch caso {
        case 1:
            sueldoBasicoInput = "2500"
            diasLaboradosInput = "30"
            tieneHijosToggle = false
            sistemaPensiones = "ONP"
            horas25Input = "0"
            horas35Input = "0"
            adelantosInput = "0"
        case 2:
            sueldoBasicoInput = "1800"
            diasLaboradosInput = "27"
            tieneHijosToggle = true
            sistemaPensiones = "ONP"
            horas25Input = "0"
            horas35Input = "0"
            adelantosInput = "0"
        case 3:
            sueldoBasicoInput = "3000"
            diasLaboradosInput = "30"
            tieneHijosToggle = true
            sistemaPensiones = "AFP"
            afpSeleccionada = "AFP Ejemplo"
            horas25Input = "4"
            horas35Input = "4"
            adelantosInput = "200"
        case 4:
            sueldoBasicoInput = "4200"
            diasLaboradosInput = "24"
            tieneHijosToggle = true
            sistemaPensiones = "AFP"
            afpSeleccionada = "AFP Ejemplo"
            horas25Input = "2"
            horas35Input = "2"
            adelantosInput = "100"
        default:
            break
        }
    }
}

struct FilaBoleta: View {
    let concepto: String
    let monto: Double
    var isBold: Bool = false
    
    var body: some View {
        HStack {
            Text(concepto)
                .font(isBold ? .subheadline : .footnote)
                .fontWeight(isBold ? .bold : .regular)
            Spacer()
            Text(String(format: "%.2f", monto))
                .font(isBold ? .subheadline : .footnote)
                .fontWeight(isBold ? .bold : .regular)
        }
    }
}
```

---

## 4. Estructura Requerida para el Archivo Excel (4 Hojas)

### Hoja 1: `Parámetros`
Almacena todas las constantes del sistema.
- Celdas con las tasas: RMV (`1230.00`), Asignación Familiar (`10%`), ONP (`13%`), EsSalud (`9%`), Horas Extras 25% (`1.25`), Horas Extras 35% (`1.35`).
- Tabla de Tasas AFP: Fondo (`10%`), Comisión (`1.60%`), Seguro (`1.35%`).

### Hoja 2: `Boleta`
Módulo de cálculo dinámico con tres bloques tabulares (Remuneraciones, Retenciones/Descuentos, Aportaciones Empleador) y el Neto a Pagar destacado. Debe usar exclusivamente referencias a la hoja de Parámetros y funciones `=ROUND(..., 2)`.

### Hoja 3: `Casos`
Cuadro comparativo automatizado que calcula simultáneamente los 4 casos oficiales de la guía más el caso propio basado en la oferta laboral real.

### Hoja 4: `Explicación`
Resumen conceptual para usuarios sin experiencia contable, describiendo en lenguaje sencillo cómo se calcula cada rubro y acompañándolo de un ejemplo numérico paso a paso.
```

eof

Quedo a tu disposición por si necesitas algún ajuste adicional en el documento generado.