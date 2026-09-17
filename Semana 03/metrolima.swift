// ============================================================================
// ESTUDIANTE: Calep Omar Neyra Taype
// CURSO: Programación Móvil Avanzada
// DOCENTE: Juan León
// INSTITUCIÓN: Tecsup
// PROYECTO: Sistema del Metro de Lima y Callao (Línea 1 y Línea 2)
// UBICACIÓN: Semana 03 / Tareametro.swift
// ============================================================================

import Foundation

// ============================================================================
// FORMATO Y SECUENCIAS ANSI PARA LA CONSOLA
// ============================================================================
extension String {
    var negrita: String { "\u{001B}[1m\(self)\u{001B}[0m" }
    var subrayado: String { "\u{001B}[4m\(self)\u{001B}[0m" }
    var verde: String { "\u{001B}[32m\(self)\u{001B}[0m" }
    var rojo: String { "\u{001B}[31m\(self)\u{001B}[0m" }
    var amarillo: String { "\u{001B}[33m\(self)\u{001B}[0m" }
    var azul: String { "\u{001B}[34m\(self)\u{001B}[0m" }
    var cian: String { "\u{001B}[36m\(self)\u{001B}[0m" }
}
// ============================================================================
// 1. ESTADO DE OPERATIVIDAD
// ============================================================================
enum EstadoServicio {
    case operativo
    case fueraDeServicio
    
    var indicador: String {
        switch self {
        case .operativo: return "(F)"
        case .fueraDeServicio: return "(NF)"
        }
    }
    
    var etiquetaVisible: String {
        switch self {
        case .operativo: return "🟢 OPERATIVA (En servicio comercial)".verde.negrita
        case .fueraDeServicio: return "🔴 NO OPERATIVA (En construcción / obras)".rojo.negrita
        }
    }
}
// ============================================================================
// 2. MODELO DE ESTACIÓN REAL
// ============================================================================
struct EstacionRed {
    let identificador: String
    let nombre: String
    let lineaPertenencia: String
    let posicion: Int
    let estado: EstadoServicio
    let accesoDiscapacidad: Bool
    let cruceAvenidas: String
    let puntosInteres: [String]
    
    func obtenerFichaDetallada(tarifa: Double) -> String {
        let cod = identificador.isEmpty ? "" : "[\(identificador)] "
        let accTexto = accesoDiscapacidad ? "♿ Accesible (Ascensores / Rampas)".verde : "🚫 Accesibilidad restringida por obras".rojo
        
        return """
        --------------------------------------------------
        📍 ESTACIÓN: \(cod)\(nombre.uppercased())
        --------------------------------------------------
        • Estado de Operación : \(estado.etiquetaVisible)
        • Red / Línea         : \(lineaPertenencia.cian) (Posición \(posicion))
        • Tarifa Adulto       : S/ \(String(format: "%.2f", tarifa).amarillo)
        • Ubicación/Cruce     : \(cruceAvenidas)
        • Accesibilidad       : \(accTexto)
        • Referencias         : \(puntosInteres.joined(separator: ", "))
        --------------------------------------------------
        """
    }
}
// ============================================================================
// 3. MODELO DE LÍNEA Y TARIFARIO
// ============================================================================
struct LineaTransporte {
    let denominacion: String
    let colorIdentificador: String
    let tarifaAdulto: Double
    let tarifaMedio: Double
    var paraderos: [EstacionRed] = []
    
    func imprimirCatalogo() {
        print("\n==========================================")
        print("RED METROPOLITANA: \(denominacion.uppercased()) (\(colorIdentificador))".negrita.cian)
        print("💵 Tarifa General: S/ \(String(format: "%.2f", tarifaAdulto)) | Medio Pasaje: S/ \(String(format: "%.2f", tarifaMedio))".amarillo)
        print("==========================================")
        for p in paraderos {
            let cod = p.identificador.isEmpty ? "" : "[\(p.identificador)] "
            let estadoTexto = (p.estado == .operativo) ? "🟢 [OPERATIVA]".verde : "🔴 [EN OBRAS]".rojo
            print("  \(p.posicion). \(cod)\(p.nombre) \(estadoTexto) — \(p.cruceAvenidas)")
        }
        print("Total de estaciones: \(paraderos.count)")
    }
}
// ============================================================================
// 4. MODELO DE INTERCAMBIO / TRANSBORDO
// ============================================================================
struct TransbordoRed {
    let origenLinea: String
    let origenEstacion: String
    let destinoLinea: String
    let destinoEstacion: String
    let modalidad: String
    let referenciaUbicacion: String
    let tiempoEstimadoMin: Int
}
// ============================================================================
// 5. GESTOR CENTRAL DE LA RED
// ============================================================================
class GestorRedTransporte {
    var lineasRed: [LineaTransporte] = []
    var listaTransbordos: [TransbordoRed] = []
    
    func registrarLinea(_ linea: LineaTransporte) { lineasRed.append(linea) }
    func registrarTransbordo(_ transbordo: TransbordoRed) { listaTransbordos.append(transbordo) }
    
    var todasLasEstaciones: [EstacionRed] {
        return lineasRed.flatMap { $0.paraderos }
    }
    
    func consultarParadero(_ patron: String) -> [(estacion: EstacionRed, tarifa: Double)] {
        var lista: [(estacion: EstacionRed, tarifa: Double)] = []
        let eEncontradas = todasLasEstaciones.filter { $0.nombre.lowercased().contains(patron.lowercased()) }
        
        for e in eEncontradas {
            let tarifa = lineasRed.first(where: { $0.denominacion == e.lineaPertenencia })?.tarifaAdulto ?? 0.0
            lista.append((e, tarifa))
        }
        return lista
    }
    
    func planificarRutaADestino(_ destinoBuscado: String) -> [(estacion: EstacionRed, hitoEncontrado: String, tarifaAdulto: Double, tarifaMedio: Double)] {
        var coincidencias: [(estacion: EstacionRed, hitoEncontrado: String, tarifaAdulto: Double, tarifaMedio: Double)] = []
        let termino = destinoBuscado.lowercased()
        
        for estacion in todasLasEstaciones {
            let linea = lineasRed.first(where: { $0.denominacion == estacion.lineaPertenencia })
            let tAdulto = linea?.tarifaAdulto ?? 0.0
            let tMedio = linea?.tarifaMedio ?? 0.0
            
            if estacion.nombre.lowercased().contains(termino) {
                coincidencias.append((estacion, "Coincidencia directa de estación", tAdulto, tMedio))
            } else {
                for hito in estacion.puntosInteres {
                    if hito.lowercased().contains(termino) {
                        coincidencias.append((estacion, hito, tAdulto, tMedio))
                    }
                }
            }
        }
        return coincidencias
    }
    
    func obtenerPorEstado(_ estadoBuscado: EstadoServicio) -> [EstacionRed] {
        return todasLasEstaciones.filter { $0.estado == estadoBuscado }
    }
    
    func obtenerConAccesoElevador() -> [EstacionRed] {
        return todasLasEstaciones.filter { $0.accesoDiscapacidad }
    }
    
    func desplegarTransbordos() {
        print("\n==========================================")
        print("🔗 PUNTOS DE TRANSBORDO E INTERCAMBIO".negrita.cian)
        print("==========================================")
        for t in listaTransbordos {
            print("• \(t.origenLinea.cian) (\(t.origenEstacion)) ⇄ \(t.destinoLinea.cian) (\(t.destinoEstacion))")
            print("  - Modalidad  : \(t.modalidad)")
            print("  - Ubicación  : \(t.referenciaUbicacion)")
            print("  - Caminata   : ~\(t.tiempoEstimadoMin) min aprox.\n")
        }
    }
}
