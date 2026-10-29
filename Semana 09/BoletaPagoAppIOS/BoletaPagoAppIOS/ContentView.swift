//
//  ContentView.swift
//  BoletaPagoAppIOS
//
//  Created by Tecsup on 27/10/26.
//

import SwiftUI

struct ContentView: View {
    @State private var calculadora = BoletaCalculadora()
    
    // Selector rápido para los 4 casos de prueba oficiales
    @State private var casoSeleccionado: Int = 1
    
    // Controles de Entrada (Nivel 1 y Nivel 2)
    @State private var sueldoBasicoInput: String = ""
    @State private var diasLaboradosInput: String = ""
    @State private var tieneHijosToggle: Bool = false
    @State private var sistemaPensiones: String = "ONP" // "ONP" o "AFP"
    @State private var afpSeleccionada: String = "AFP Ejemplo"
    @State private var horas25Input: String = ""
    @State private var horas35Input: String = ""
    @State private var adelantosInput: String = ""
    
    // Control de visualización y alertas
    @State private var mostrado: Bool = false
    @State private var mostrarAlerta: Bool = false
    @State private var mensajeAlerta: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Encabezado
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
                    
                    // Selector de Casos de la Guía
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
                    
                    // Formulario de Datos de Entrada (Nivel 1 y 2)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Parámetros de Entrada")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        // Sueldo Básico (> 0)
                        HStack {
                            Text("Sueldo básico (S/):")
                            Spacer()
                            TextField("Ej. 2500", text: $sueldoBasicoInput)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                        }
                        
                        // Días laborados (Entre 1 y 30)
                        HStack {
                            Text("Días laborados (1-30):")
                            Spacer()
                            TextField("Ej. 30", text: $diasLaboradosInput)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                        }
                        
                        // ¿Tiene hijos? (Picker No / Sí)
                        Picker("¿Tiene hijos?", selection: $tieneHijosToggle) {
                            Text("No").tag(false)
                            Text("Sí").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        // Sistema de pensiones (Picker ONP / AFP)
                        Picker("Sistema de pensiones", selection: $sistemaPensiones) {
                            Text("ONP").tag("ONP")
                            Text("AFP").tag("AFP")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        // AFP Específica (Nivel 2: Solo aparece si eligió AFP)
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
                        
                        // Horas extras 25% (>= 0)
                        HStack {
                            Text("Horas extras 25%:")
                            Spacer()
                            TextField("Ej. 0", text: $horas25Input)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                        }
                        
                        // Horas extras 35% (>= 0)
                        HStack {
                            Text("Horas extras 35%:")
                            Spacer()
                            TextField("Ej. 0", text: $horas35Input)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                        }
                        
                        // Adelantos (>= 0)
                        HStack {
                            Text("Adelantos (S/):")
                            Spacer()
                            TextField("Ej. 0.00", text: $adelantosInput)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                        }
                        
                        // Botón de cálculo con validaciones estrictas
                        Button(action: {
                            // Validación Sueldo Básico (> 0)
                            guard let basico = Double(sueldoBasicoInput), basico > 0 else {
                                mensajeAlerta = "El sueldo básico debe ser mayor a cero."
                                mostrarAlerta = true
                                mostrado = false
                                return
                            }
                            
                            // Validación Días Laborados (Entre 1 y 30)
                            guard let dias = Int(diasLaboradosInput), dias >= 1, dias <= 30 else {
                                mensajeAlerta = "Los días laborados deben estar entre 1 y 30."
                                mostrarAlerta = true
                                mostrado = false
                                return
                            }
                            
                            // Validaciones Horas Extras y Adelantos (>= 0)
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
                    
                    // Resultado en Bloques verticales (Remuneraciones, Descuentos, Aportaciones) con ceros exactos
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
                            
                            // Bloque 2: RETENCIONES / DESCUENTOS (Con ceros en los no aplicables)
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
                            
                            // Neto a Pagar
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
    
    // Autocompletado de los 4 casos de prueba de la guía
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
