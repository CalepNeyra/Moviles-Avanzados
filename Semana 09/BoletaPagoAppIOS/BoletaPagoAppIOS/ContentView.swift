//
//  ContentView.swift
//  BoletaPagoAppIOS
//
//  Created by Tecsup on 27/10/26.
//

import SwiftUI

struct ContentView: View {
    // Inicialización con los datos predeterminados (Ejemplo: Caso 3 de la guía)
    @State private var boleta = BoletaModel(
        sueldoBasico: 3000.0,
        diasLaborados: 30.0,
        tieneHijos: true,
        sistemaPensiones: "AFP",
        afpSeleccionada: "AFP Ejemplo",
        horas25: 4.0,
        horas35: 4.0,
        adelanto: 200.0
    )
    
    let sistemasPensiones = ["ONP", "AFP"]
    let listaAFPs = ["AFP Ejemplo", "Habitat (flujo)", "Integra (flujo)", "Prima (flujo)", "Profuturo (flujo)"]

    var body: some View {
        NavigationView {
            Form {
                // Sección de entradas editables (Equivalente al color crema del Excel)
                Section(header: Text("1. Datos de Entrada (Variables)")) {
                    HStack {
                        Text("Sueldo Básico (S/)")
                        Spacer()
                        TextField("Sueldo", value: $boleta.sueldoBasico, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Días Laborados")
                        Spacer()
                        TextField("Días", value: $boleta.diasLaborados, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Toggle("¿Tiene hijos?", isOn: $boleta.tieneHijos)
                    
                    Picker("Sistema de Pensiones", selection: $boleta.sistemaPensiones) {
                        ForEach(sistemasPensiones, id: \.self) { sistema in
                            Text(sistema).tag(sistema)
                        }
                    }
                    
                    // Selector condicional: Solo aparece si el sistema elegido es AFP
                    if boleta.sistemaPensiones == "AFP" {
                        Picker("AFP Seleccionada", selection: $boleta.afpSeleccionada) {
                            ForEach(listaAFPs, id: \.self) { afp in
                                Text(afp).tag(afp)
                            }
                        }
                    }
                    
                    HStack {
                        Text("Horas Extras 25%")
                        Spacer()
                        TextField("Horas", value: $boleta.horas25, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Horas Extras 35%")
                        Spacer()
                        TextField("Horas", value: $boleta.horas35, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Adelantos (S/)")
                        Spacer()
                        TextField("Adelanto", value: $boleta.adelanto, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                // Sección de ingresos calculados
                Section(header: Text("2. Remuneraciones")) {
                    HStack { Text("Sueldo computable"); Spacer(); Text("S/ \(boleta.sueldoComputable, specifier: "%.2f")") }
                    HStack { Text("Asignación familiar"); Spacer(); Text("S/ \(boleta.asignacionFamiliar, specifier: "%.2f")") }
                    HStack { Text("Horas extras 25%"); Spacer(); Text("S/ \(boleta.montoHE25, specifier: "%.2f")") }
                    HStack { Text("Horas extras 35%"); Spacer(); Text("S/ \(boleta.montoHE35, specifier: "%.2f")") }
                    
                    HStack {
                        Text("Total remuneraciones").bold()
                        Spacer()
                        Text("S/ \(boleta.totalRemuneraciones, specifier: "%.2f")").bold()
                    }
                }

                // Sección de retenciones (ONP o desglose de AFP)
                Section(header: Text("3. Retenciones y Descuentos")) {
                    if boleta.sistemaPensiones == "ONP" {
                        HStack { Text("ONP (13%)"); Spacer(); Text("S/ \(boleta.montoONP, specifier: "%.2f")") }
                    } else {
                        HStack { Text("AFP Fondo (10%)"); Spacer(); Text("S/ \(boleta.afpFondo, specifier: "%.2f")") }
                        HStack { Text("AFP Comisión"); Spacer(); Text("S/ \(boleta.afpComision, specifier: "%.2f")") }
                        HStack { Text("AFP Seguro"); Spacer(); Text("S/ \(boleta.afpSeguro, specifier: "%.2f")") }
                    }
                    HStack { Text("Adelantos"); Spacer(); Text("S/ \(boleta.adelanto, specifier: "%.2f")") }
                    
                    HStack {
                        Text("Total descuentos").bold()
                        Spacer()
                        Text("S/ \(boleta.totalDescuentos, specifier: "%.2f")").bold()
                    }
                }

                // Sección del neto líquido y EsSalud empresarial
                Section(header: Text("4. Aportes del Empleador y Neto Final")) {
                    HStack { Text("EsSalud (9%)"); Spacer(); Text("S/ \(boleta.esSaludEmpleador, specifier: "%.2f")") }
                    HStack { Text("Costo para el empleador"); Spacer(); Text("S/ \(boleta.costoTotalEmpleador, specifier: "%.2f")") }
                    
                    HStack {
                        Text("NETO A PAGAR").font(.headline).foregroundColor(.blue)
                        Spacer()
                        Text("S/ \(boleta.netoAPagar, specifier: "%.2f")").font(.headline).foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Cálculo Boleta Perú")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
