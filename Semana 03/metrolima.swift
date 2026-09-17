// ============================================================================
// ESTUDIANTE: Calep Omar Neyra Taype
// CURSO: Programación Móvil Avanzada
// DOCENTE: Juan León
// INSTITUCIÓN: Tecsup
// PROYECTO: Sistema del Metro de Lima y Callao (Línea 1 y Línea 2)
// UBICACIÓN: Semana 03 / metrolima.swift
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
// GESTIÓN DE TARJETA Y ESTADOS DE COBRO (REGLAS LÍNEA 1)
// ============================================================================
enum ResultadoPago {
    case exito(tarjetaActualizada: TarjetaTransporte)
    case parcial(tarjetaSinSaldo: TarjetaTransporte, deudaPendiente: Double)
    case insuficiente(faltante: Double)
}

struct TarjetaTransporte {
    var saldo: Double
    static let saldoMaximoPermitido: Double = 100.0 // Límite real oficial de Línea 1
    
    // Función de recarga con validación de tope máximo
    mutating func recargar(monto: Double) -> (exito: Bool, mensaje: String) {
        if monto <= 0 {
            return (false, "El monto a recargar debe ser mayor a S/ 0.00.")
        }
        
        let nuevoSaldoCalculado = saldo + monto
        if nuevoSaldoCalculado > TarjetaTransporte.saldoMaximoPermitido {
            let maximoPosibleRecarga = TarjetaTransporte.saldoMaximoPermitido - saldo
            return (false, "Excede el límite máximo de la tarjeta (S/ 100.00). Saldo actual: S/ \(String(format: "%.2f", saldo)). Recarga máxima permitida: S/ \(String(format: "%.2f", maximoPosibleRecarga)).")
        }
        
        saldo = nuevoSaldoCalculado
        return (true, "Recarga exitosa. Nuevo saldo: S/ \(String(format: "%.2f", saldo))")
    }
    
    // Cobro inmutable que retorna la nueva tarjeta con saldo descontado
    func realizarCobro(tarifa: Double) -> ResultadoPago {
        if saldo >= tarifa {
            let nuevoSaldo = saldo - tarifa
            return .exito(tarjetaActualizada: TarjetaTransporte(saldo: nuevoSaldo))
            
        } else if saldo > 0 {
            let deuda = tarifa - saldo
            return .parcial(tarjetaSinSaldo: TarjetaTransporte(saldo: 0.0), deudaPendiente: deuda)
            
        } else {
            let faltante = tarifa - saldo
            return .insuficiente(faltante: faltante)
        }
    }
}

// Variable Global para mantener el estado de tu tarjeta durante toda la sesión
var miTarjetaUsuario = TarjetaTransporte(saldo: 10.00) // Saldo inicial predeterminado

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
            print("  - Modalidad   : \(t.modalidad)")
            print("  - Ubicación   : \(t.referenciaUbicacion)")
            print("  - Caminata    : ~\(t.tiempoEstimadoMin) min aprox.\n")
        }
    }
}

func imprimirLeyendaSistema() {
    print("\n==========================================")
    print("📖 LEYENDA TÉCNICA Y SIMBOLOGÍA DEL SISTEMA".negrita.cian)
    print("==========================================")
    print(" (F) / 🟢 : Estación Operativa (En servicio activo)")
    print(" (NF) / 🔴: Estación No Operativa (En proyecto o infraestructura en obras)")
    print(" [E-XX]   : Código oficial de infraestructura asignado")
    print(" 💳        : Saldo máximo permitido en tarjeta: S/ 100.00")
    print(" ♿        : Estación adaptada para personas con movilidad reducida")
    print(" 🔗        : Nodo de transferencia entre líneas")
    print("==========================================\n")
}

// ============================================================================
// CONFIGURACIÓN DE LA BASE DE DATOS DE LA RED
// ============================================================================
let redCentral = GestorRedTransporte()

// LÍNEA 1
var l1 = LineaTransporte(denominacion: "Linea 1", colorIdentificador: "Verde", tarifaAdulto: 1.50, tarifaMedio: 0.75)
let datosL1: [(nom: String, cruce: String, hitos: [String], acc: Bool)] = [
    ("Villa El Salvador", "Av. Separadora Industrial con Av. Velasco", ["Parque Industrial", "Muni Villa El Salvador"], true),
    ("Parque Industrial", "Av. Separadora Industrial con Av. El Sol", ["Zona Industrial Villa El Salvador"], true),
    ("Pumacahua", "Av. Unión con Av. Pumacahua", ["Hospital de la Solidaridad VMT"], false),
    ("Villa Maria", "Av. Pachacútec con Av. San Aconcagua", ["Plaza de Armas VMT"], false),
    ("Maria Auxiliadora", "Av. Pachacútec con Av. Miguel Iglesias", ["Hospital María Auxiliadora"], false),
    ("San Juan", "Av. Los Héroes con Av. San Juan", ["C.C. Open Plaza Atocongo"], true),
    ("Atocongo", "Av. Los Héroes con Av. Circunvalación", ["Mall del Sur", "Puente Atocongo"], true),
    ("Jorge Chavez", "Av. Tomás Marsano con Av. Jorge Chávez", ["Plaza Vea Higuereta"], true),
    ("Ayacucho", "Av. Tomás Marsano con Av. Ayacucho", ["Plaza de Surco", "Parque Amistad"], true),
    ("Cabitos", "Av. Aviación con Av. Benavides", ["Óvalo Higuereta", "Polvos Higuereta"], true),
    ("Angamos", "Av. Aviación con Av. Angamos Este", ["Open Plaza Angamos", "INEN Instituto Neoplásicas"], true),
    ("San Borja Sur", "Av. Aviación con Av. San Borja Sur", ["Parque de la Felicidad", "Pentagonito"], false),
    ("La Cultura", "Av. Javier Prado con Av. Aviación", ["Teatro Nacional", "Museo de la Nación", "Biblioteca Nacional"], true),
    ("Arriola", "Av. Aviación con Av. Pablo Cánepa", ["Mercado de Frutas", "La Victoria"], true),
    ("Gamarra", "Av. Aviación con Jr. Hipólito Unanue", ["Emporio Comercial Gamarra", "Parque Cánepa"], true),
    ("Miguel Grau", "Av. Miguel Grau con Av. Aviación", ["Hospital Almenara", "Parque Universitario"], true),
    ("El Angel", "Av. Locumba con Jr. Ancash", ["Cementerio El Ángel"], true),
    ("Presbitero Maestro", "Av. Locumba con Av. Cementerio", ["Museo Cementerio Presbítero Maestro"], true),
    ("Caja de Agua", "Av. Próceres de la Independencia con Jr. Lima", ["Entrada SJL"], true),
    ("Piramide del Sol", "Av. Próceres con Av. Pirámide del Sol", ["Zona Comercial Zárate"], true),
    ("Los Jardines", "Av. Próceres N° 1600", ["Plaza Vea Zárate", "Metro de Hacienda"], true),
    ("Los Postes", "Av. Próceres N° 2100", ["Parque Zonal Huiracocha"], true),
    ("San Carlos", "Av. Próceres con Av. El Sol", ["Universidad CTP", "UTP SJL"], true),
    ("San Martin", "Av. Fernando Wiesse con Av. San Martín", ["Mercado San Martín"], true),
    ("Santa Rosa", "Av. Fernando Wiesse con Av. Santa Rosa", ["Comisaría Santa Rosa"], true),
    ("Bayovar", "Av. Fernando Wiesse con Av. Bayóvar", ["Plaza Vea Bayóvar", "Universidad UMA"], true)
]

for (idx, d) in datosL1.enumerated() {
    l1.paraderos.append(EstacionRed(identificador: "", nombre: d.nom, lineaPertenencia: "Linea 1", posicion: idx + 1, estado: .operativo, accesoDiscapacidad: d.acc, cruceAvenidas: d.cruce, puntosInteres: d.hitos))
}
redCentral.registrarLinea(l1)

// LÍNEA 2
var l2 = LineaTransporte(denominacion: "Linea 2", colorIdentificador: "Amarillo", tarifaAdulto: 1.40, tarifaMedio: 0.70)
let datosL2: [(nom: String, cruce: String, hitos: [String])] = [
    ("Puerto del Callao", "Av. Guardia Chalaca con Av. Buenos Aires", ["Puerto del Callao", "Fortaleza Real Felipe"]),
    ("Buenos Aires", "Av. Oscar R. Benavides con Av. Buenos Aires", ["Mercado Central del Callao"]),
    ("Juan Pablo II", "Av. Oscar R. Benavides con Av. Juan Pablo II", ["Minka", "Universidad del Callao"]),
    ("Insurgentes", "Av. Oscar R. Benavides con Av. Insurgentes", ["Bellavista Callao"]),
    ("Carmen de la Legua", "Av. Faucett con Av. Oscar R. Benavides", ["Hospital San José"]),
    ("Oscar R. Benavides", "Av. Oscar R. Benavides con Av. Colonial", ["Mallplaza Bellavista"]),
    ("San Marcos", "Av. Venezuela con Av. Universitario", ["UNMSM Universidad San Marcos"]),
    ("Elio", "Av. Venezuela con Av. Germán Amezaga", ["Unidad Vecinal Muelle"]),
    ("La Alborada", "Av. Venezuela con Av. Alejandro Bertello", ["Pueblo Libre Norte"]),
    ("Tingo Maria", "Av. Venezuela con Av. Tingo María", ["Universidad Simón Bolívar"]),
    ("Parque Murillo", "Av. Arica con Av. Aguarico", ["Plaza Bolognesi", "Breña"]),
    ("Plaza Bolognesi", "Av. Arica con Guzmán Blanco", ["Plaza Bolognesi", "Paseo Colón"]),
    ("Estacion Central", "Paseo Colón con Paseo de la República", ["Centro Cívico", "Estadio Nacional", "Plaza San Martín"]),
    ("Manco Capac", "Av. 28 de Julio con Av. Manco Cápac", ["Plaza Manco Cápac"]),
    ("Cangallo", "Av. 28 de Julio con Jr. Cangallo", ["Hospital Nacional Dos de Mayo"]),
    ("28 de Julio", "Av. 28 de Julio con Av. Aviación", ["Emporio Gamarra Norte"]),
    ("Nicolas Ayllon", "Av. Nicolás Ayllón con Av. México", ["Plaza Vitarte"]),
    ("Circunvalacion", "Av. Nicolás Ayllón con Av. Circunvalación", ["El Agustino"]),
    ("San Juan de Dios", "Av. Nicolás Ayllón con Av. San Juan", ["Clínica San Juan de Dios"]),
    ("Evitamiento", "Carretera Central con Vía Evitamiento", ["Mall Aventura Santa Anita"]),
    ("Ovalo Santa Anita", "Carretera Central con Av. Los Ruiseñores", ["Óvalo Santa Anita"]),
    ("Colectora Industrial", "Carretera Central con Av. Colectora", ["Zona Industrial Ate"]),
    ("Hermilio Valdizan", "Carretera Central con Av. Valdizán", ["Hospital Hermilio Valdizán"]),
    ("Mercado Santa Anita", "Carretera Central con Av. Metropolitano", ["Mercado Mayorista de Santa Anita"]),
    ("Vista Alegre", "Carretera Central con Av. Vista Alegre", ["Ceres Medio"]),
    ("Prolongacion Javier Prado", "Carretera Central con Prolongación Javier Prado", ["Estadio Monumental U"]),
    ("Municipalidad de Ate", "Carretera Central con Av. Nicolás de Piérola", ["Municipalidad de Ate"])
]

for (idx, d) in datosL2.enumerated() {
    let num = idx + 1
    let cod = String(format: "E-%02d", num)
    let enServicio = (num >= 20 && num <= 24)
    l2.paraderos.append(EstacionRed(identificador: cod, nombre: d.nom, lineaPertenencia: "Linea 2", posicion: num, estado: enServicio ? .operativo : .fueraDeServicio, accesoDiscapacidad: enServicio, cruceAvenidas: d.cruce, puntosInteres: d.hitos))
}
redCentral.registrarLinea(l2)

// TRANSBORDOS
redCentral.registrarTransbordo(TransbordoRed(origenLinea: "Linea 1", origenEstacion: "Gamarra", destinoLinea: "Linea 2", destinoEstacion: "28 de Julio", modalidad: "Conexión peatonal asistida", referenciaUbicacion: "Av. Aviación esquina con Av. 28 de Julio", tiempoEstimadoMin: 6))
redCentral.registrarTransbordo(TransbordoRed(origenLinea: "Linea 2", origenEstacion: "Estacion Central", destinoLinea: "Metropolitano", destinoEstacion: "Estación Central", modalidad: "Hub Intermodal Subterráneo", referenciaUbicacion: "Paseo de la República / Centro Cívico", tiempoEstimadoMin: 2))

// ============================================================================
// CONSOLA INTERACTIVA
// ============================================================================
var sistemaActivo = true

while sistemaActivo {
    print("\n--------------------------------------------------")
    print("   SISTEMA METROPOLITANO Y CALCULADORA DE PASAJE".negrita.cian)
    print("             Desarrollado por: Calep Neyra")
    print("--------------------------------------------------")
    print("1. Consultar estaciones y tarifas por línea")
    print("2. Buscar ficha técnica y costo de estación")
    print("3. Planificar ruta y simular cobro en torniquete")
    print("4. Ver mi saldo actual y recargar tarjeta 💳")
    print("5. Ver puntos de transbordo e intercambios")
    print("6. Filtrar catálogo (Estado / Accesibilidad)")
    print("7. Ver Leyenda de Simbología")
    print("8. Salir")
    print("Seleccione una opción: ".negrita)
    
    let entrada = readLine() ?? ""
    
    switch entrada {
    case "1":
        print("\nIngrese el número de línea a consultar (1 - 2):")
        if let num = Int(readLine() ?? ""), num >= 1 && num <= redCentral.lineasRed.count {
            redCentral.lineasRed[num - 1].imprimirCatalogo()
        } else {
            print("❌ Selección fuera de rango.".rojo)
        }
        
    case "2":
        print("\nIngrese el nombre de la estación:")
        let termino = readLine() ?? ""
        let resultados = redCentral.consultarParadero(termino)
        
        if resultados.isEmpty {
            print("❌ No se registraron estaciones con ese nombre.".rojo)
        } else {
            for res in resultados {
                print(res.estacion.obtenerFichaDetallada(tarifa: res.tarifa))
            }
        }
        
    case "3":
        print("\n¿A qué lugar o punto de interés deseas ir?".cian.negrita)
        print("Ejemplos: Gamarra, Estadio Nacional, Minka, Teatro Nacional, Mall del Sur")
        let destino = readLine() ?? ""
        let rutas = redCentral.planificarRutaADestino(destino)
        
        if rutas.isEmpty {
            print("❌ No se hallaron estaciones con cercanía a '\(destino)'.".rojo)
        } else {
            print("\n==================================================")
            print("🗺️ RUTAS Y COSTOS SUGERIDOS PARA LLEGAR A: '\(destino.uppercased())'".negrita.cian)
            print("==================================================")
            
            for (idx, r) in rutas.enumerated() {
                let estadoTexto = (r.estacion.estado == .operativo) ? "🟢 [OPERATIVA]".verde : "🔴 [EN OBRAS]".rojo
                print("Opción \(idx + 1): Bajar en estación \(r.estacion.nombre.uppercased().negrita) \(estadoTexto)")
                print("  • Red/Línea       : \(r.estacion.lineaPertenencia.cian)")
                print("  • Ubicación       : \(r.estacion.cruceAvenidas)")
                print("  • Referencia      : \(r.hitoEncontrado)")
                print("  • Pasaje Adulto   : S/ \(String(format: "%.2f", r.tarifaAdulto).amarillo)")
                print("  • Pasaje Medio    : S/ \(String(format: "%.2f", r.tarifaMedio).amarillo)\n")
            }
            
            let costoRequerido = rutas[0].tarifaAdulto
            
            print("--------------------------------------------------")
            print("💳 COBRO AUTOMÁTICO EN TORNIQUETE".negrita.amarillo)
            print("• Pasaje del viaje: S/ \(String(format: "%.2f", costoRequerido))")
            print("• Saldo actual en tu tarjeta: S/ \(String(format: "%.2f", miTarjetaUsuario.saldo))".cian)
            print("¿Deseas validar tu ingreso al torniquete? (s/n):")
            
            let confirmar = (readLine() ?? "").lowercased()
            if confirmar == "s" || confirmar == "si" {
                let resultado = miTarjetaUsuario.realizarCobro(tarifa: costoRequerido)
                
                switch resultado {
                case .exito(let tarjetaNueva):
                    miTarjetaUsuario = tarjetaNueva // Se actualiza la tarjeta global
                    print("\n✅ ¡PAGO EXITOSO! TORNIQUETE ABIERTO".verde.negrita)
                    print("• Saldo restante disponible: S/ \(String(format: "%.2f", miTarjetaUsuario.saldo))".verde)
                    
                case .parcial(_, let deuda):
                    miTarjetaUsuario.saldo = 0.0
                    print("\n⚠️ PAGO PARCIAL APLICADO".amarillo.negrita)
                    print("• Se agotó tu saldo disponible. Deuda en estación: S/ \(String(format: "%.2f", deuda))".rojo)
                    print("👉 Acércate a la boletería a cancelar el saldo pendiente para ingresar.")
                    
                case .insuficiente(let faltante):
                    print("\n🔴 SALDO INSUFICIENTE".rojo.negrita)
                    print("• Saldo actual: S/ \(String(format: "%.2f", miTarjetaUsuario.saldo)) | Requerido: S/ \(String(format: "%.2f", costoRequerido))")
                    print("• Te faltan S/ \(String(format: "%.2f", faltante)) para abordar.".rojo)
                    print("👉 Usa la opción 4 del menú para recargar tu tarjeta.")
                }
            } else {
                print("Operación cancelada. No se realizó ningún cobro.")
            }
        }
        
    case "4":
        print("\n==========================================")
        print("💳 CONSULTA Y RECARGA DE TARJETA METRO".negrita.cian)
        print("==========================================")
        print("• Saldo actual disponible: S/ \(String(format: "%.2f", miTarjetaUsuario.saldo))".amarillo.negrita)
        print("• Límite máximo de tarjeta: S/ 100.00".cian)
        print("------------------------------------------")
        print("1. Recargar saldo")
        print("2. Volver al menú principal")
        print("Seleccione una opción:")
        
        let subOp = readLine() ?? ""
        if subOp == "1" {
            print("\nIngrese el monto a recargar (S/):")
            print("📌 Nota: El saldo total acumulado NO puede superar S/ 100.00.")
            if let entradaMonto = readLine(), let montoRecarga = Double(entradaMonto) {
                let resRecarga = miTarjetaUsuario.recargar(monto: montoRecarga)
                if resRecarga.exito {
                    print("\n✅ \(resRecarga.mensaje)".verde.negrita)
                } else {
                    print("\n❌ \(resRecarga.mensaje)".rojo.negrita)
                }
            } else {
                print("❌ Monto ingresado no válido.".rojo)
            }
        }
        
    case "5":
        redCentral.desplegarTransbordos()
        
    case "6":
        print("\n--- CRITERIOS DE FILTRADO ---".negrita.cian)
        print("1. Ver solo estaciones en funcionamiento (🟢)")
        print("2. Ver estaciones en proyecto/obras (🔴)")
        print("3. Ver estaciones con acceso para discapacidad (♿)")
        print("Elija una opción:")
        
        let subOp = readLine() ?? ""
        switch subOp {
        case "1":
            let ops = redCentral.obtenerPorEstado(.operativo)
            print("\n=== ESTACIONES EN FUNCIONAMIENTO (\(ops.count)) ===".verde.negrita)
            ops.forEach { print("  • [\($0.lineaPertenencia.cian)] \($0.nombre) — \($0.cruceAvenidas)") }
        case "2":
            let noOps = redCentral.obtenerPorEstado(.fueraDeServicio)
            print("\n=== ESTACIONES EN PROYECTO / OBRAS (\(noOps.count)) ===".rojo.negrita)
            noOps.forEach { print("  • [\($0.lineaPertenencia.cian)] \($0.nombre) — \($0.cruceAvenidas)") }
        case "3":
            let adaptadas = redCentral.obtenerConAccesoElevador()
            print("\n=== ACCESO ADAPTADO PARA DISCAPACIDAD (\(adaptadas.count)) ===".azul.negrita)
            adaptadas.forEach { print("  • [\($0.lineaPertenencia.cian)] \($0.nombre) ♿ — \($0.cruceAvenidas)") }
        default:
            print("❌ Opción de filtro no válida.".rojo)
        }
        
    case "7":
        imprimirLeyendaSistema()
        
    case "8":
        sistemaActivo = false
        print("\nCerrando el sistema de transporte. ¡Éxitos, Calep!".verde.negrita)
        
    default:
        print("❌ Opción inválida. Intente de nuevo.".rojo)
    }
}
