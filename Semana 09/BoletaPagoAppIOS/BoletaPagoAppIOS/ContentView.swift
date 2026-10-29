//
//  ContentView.swift
//  BoletaPagoAppIOS
//
//  Created by Tecsup on 27/10/26.
//

import SwiftUI

struct ContentView: View {
    @State private var calculadora = BoletaCalculadora()
    
    // Selector rápido de los 4 casos de la guía
    @State private var casoSeleccionado: Int = 1
    
    // Campos vacíos por defecto
    @State private var sueldoBasicoInput: String = ""
    @State private var diasLaboradosInput: String = ""
    @State private var tieneHijosToggle: Bool = false
    @State private var esSistemaONP: Bool = true
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
                    
                    // Selector de Casos de Prueba Oficiales
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
                    
                    // Formulario de Parámetros
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Parámetros del Mes")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        HStack {
                            Text("Sueldo Básico (S/):")
                            Spacer()
                            TextField("Ej. 2500", text: $sueldoBasicoInput)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                        }
                        
                        HStack {
                            Text("Días Laborados (1-30):")
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
                        
                        Picker("Sistema de Pensiones", selection: $esSistemaONP) {
                            Text("ONP (13%)").tag(true)
                            Text("AFP Ejemplo").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Divider()
                        
                        HStack {
                            Text("Horas Extras 25% (Cant):")
                            Spacer()
                            TextField("Ej. 0", text: $horas25Input)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                        }
                        
                        HStack {
                            Text("Horas Extras 35% (Cant):")
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
                        
                        // Botón Calcular con validación de campos vacíos
                        Button(action: {
                            guard let basico = Double(sueldoBasicoInput), basico > 0 else {
                                mensajeAlerta = "Faltan datos solicitados: Ingrese un sueldo básico válido."
                                mostrarAlerta = true
                                mostrado = false
                                return
                            }
                            
                            guard let dias = Int(diasLaboradosInput), dias > 0, dias <= 30 else {
                                mensajeAlerta = "Faltan datos solicitados: Los días laborados deben ser entre 1 y 30."
                                mostrarAlerta = true
                                mostrado = false
                                return
                            }
                            
                            let h25 = Double(horas25Input) ?? 0.0
                            let h35 = Double(horas35Input) ?? 0.0
                            let adelanto = Double(adelantosInput) ?? 0.0
                            
                            calculadora.calcular(
                                sueldoBasico: basico,
                                diasLaborados: dias,
                                tieneHijos: tieneHijosToggle,
                                esONP: esSistemaONP,
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
                        Alert(title: Text("Aviso"), message: Text(mensajeAlerta), dismissButton: .default(Text("OK")))
                    }
                    
                    // Resultados en bloques corporativos (Estilo boleta real)
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
                            
                            // Bloque 2: RETENCIONES / DESCUENTOS (Muestra 0.00 en lo no aplicable)
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
    
    // Función que autocompleta los 4 casos de la guía
    func cargarDatosCaso(_ caso: Int) {
        switch caso {
        case 1:
            sueldoBasicoInput = "2500"
            diasLaboradosInput = "30"
            tieneHijosToggle = false
            esSistemaONP = true
            horas25Input = "0"
            horas35Input = "0"
            adelantosInput = "0"
        case 2:
            sueldoBasicoInput = "1800"
            diasLaboradosInput = "27"
            tieneHijosToggle = true
            esSistemaONP = true
            horas25Input = "0"
            horas35Input = "0"
            adelantosInput = "0"
        case 3:
            sueldoBasicoInput = "3000"
            diasLaboradosInput = "30"
            tieneHijosToggle = true
            esSistemaONP = false
            horas25Input = "4"
            horas35Input = "4"
            adelantosInput = "200"
        case 4:
            sueldoBasicoInput = "4200"
            diasLaboradosInput = "24"
            tieneHijosToggle = true
            esSistemaONP = false
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
