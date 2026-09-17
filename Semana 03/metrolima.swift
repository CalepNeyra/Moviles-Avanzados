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
    static let saldoMaximoPermitido: Double = 100.0 // Límite real oficial
    
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

var miTarjetaUsuario = TarjetaTransporte(saldo: 10.00)

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
        for (idx, p) in paraderos.enumerated() {
            let cod = p.identificador.isEmpty ? "" : "[\(p.identificador)] "
            let estadoTexto = (p.estado == .operativo) ? "🟢 [OPERATIVA]".verde : "🔴 [EN OBRAS]".rojo
            print("  \(idx + 1). \(cod)\(p.nombre) \(estadoTexto) — \(p.cruceAvenidas)")
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
    
    // VER RESUMEN EXCLUSIVO DE LÍNEAS
    func listarSoloLineas() {
        print("\n==========================================")
        print("🚇 LÍNEAS REGISTRADAS EN LA RED".negrita.cian)
        print("==========================================")
        for (idx, l) in lineasRed.enumerated() {
            print("\(idx + 1). \(l.denominacion.uppercased().negrita) (Color: \(l.colorIdentificador))")
            print("   • Tarifa General : S/ \(String(format: "%.2f", l.tarifaAdulto))".amarillo)
            print("   • Medio Pasaje   : S/ \(String(format: "%.2f", l.tarifaMedio))")
            print("   • Estaciones     : \(l.paraderos.count) paraderos en total\n")
        }
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
    
    // MÓDULO ADMINISTRADOR: INSERTAR ESTACIÓN EN CUALQUIER POSICIÓN
    func insertarEstacion(numLinea: Int, posicion: Int, nombreEstacion: String, cruce: String) -> (exito: Bool, tarifa: Double, lineaNombre: String) {
        guard numLinea >= 1 && numLinea <= lineasRed.count else {
            return (false, 0.0, "")
        }
        
        let indexLinea = numLinea - 1
        let totalActual = lineasRed[indexLinea].paraderos.count
        
        let posTarget = max(1, min(posicion, totalActual + 1))
        let indexInsertar = posTarget - 1
        let codigoGen = String(format: "E-%02d", posTarget)
        
        let nuevaEstacion = EstacionRed(
            identificador: codigoGen,
            nombre: nombreEstacion,
            lineaPertenencia: lineasRed[indexLinea].denominacion,
            posicion: posTarget,
            estado: .operativo,
            accesoDiscapacidad: true,
            cruceAvenidas: cruce,
            puntosInteres: ["Estación Intercalada / Nuevo Paradero"]
        )
        
        lineasRed[indexLinea].paraderos.insert(nuevaEstacion, at: indexInsertar)
        
        return (true, lineasRed[indexLinea].tarifaAdulto, lineasRed[indexLinea].denominacion)
    }
    
    // MÓDULO ADMINISTRADOR: CREAR NUEVA LÍNEA
    func crearNuevaLinea(denominacion: String, color: String, tarifaAdulto: Double, tarifaMedio: Double) {
        let nuevaLinea = LineaTransporte(
            denominacion: denominacion,
            colorIdentificador: color,
            tarifaAdulto: tarifaAdulto,
            tarifaMedio: tarifaMedio
        )
        registrarLinea(nuevaLinea)
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
// CONSOLA INTERACTIVA (MENÚ PRINCIPAL Y SUS OPCIONES)
// ============================================================================
var sistemaActivo = true

while sistemaActivo {
    print("\n--------------------------------------------------")
    print("   SISTEMA METROPOLITANO Y CALCULADORA DE PASAJE".negrita.cian)
    print("             Desarrollado por: Calep Neyra")
    print("--------------------------------------------------")
    print("1. Consultar líneas o catálogo de estaciones")
    print("2. Buscar ficha técnica y costo de estación")
    print("3. Planificar ruta y simular cobro en torniquete")
    print("4. Ver mi saldo actual y recargar tarjeta 💳")
    print("5. Ver puntos de transbordo e intercambios")
    print("6. Filtrar catálogo (Estado / Accesibilidad)")
    print("7. Modo Administrador 🛠️")
    print("8. Ver Leyenda de Simbología")
    print("9. Salir")
    print("Seleccione una opción: ".negrita)
    
    let entrada = readLine() ?? ""
    
    switch entrada {
        
    // 🔍 === [MÓDULO 1: CONSULTAR LÍNEAS O ESTACIONES] ===
    case "1":
        print("\n--- CONSULTA DE RED ---".negrita.cian)
        print("1. Ver lista general de Líneas (Resumen)")
        print("2. Ver paraderos completos de una Línea")
        print("Seleccione una opción:")
        
        let subConsulta = readLine() ?? ""
        if subConsulta == "1" {
            redCentral.listarSoloLineas()
        } else if subConsulta == "2" {
            print("\nIngrese el número de línea a consultar:")
            for (i, l) in redCentral.lineasRed.enumerated() {
                print("\(i + 1). \(l.denominacion) (\(l.colorIdentificador))")
            }
            if let num = Int(readLine() ?? ""), num >= 1 && num <= redCentral.lineasRed.count {
                redCentral.lineasRed[num - 1].imprimirCatalogo()
            } else {
                print("❌ Selección fuera de rango.".rojo)
            }
        } else {
            print("❌ Opción inválida.".rojo)
        }
        
    // 🔍 === [MÓDULO 2: BUSCAR FICHA TÉCNICA Y COSTO DE ESTACIÓN] ===
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
        
    // 🔍 === [MÓDULO 3: PLANIFICAR RUTA Y SIMULAR COBRO EN TORNIQUETE] ===
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
                    miTarjetaUsuario = tarjetaNueva
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
        
    // 🔍 === [MÓDULO 4: GESTIÓN DE TARJETA, CONSULTA DE SALDO Y RECARGA] ===
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
        
    // 🔍 === [MÓDULO 5: VER PUNTOS DE TRANSBORDO E INTERCAMBIOS] ===
    case "5":
        redCentral.desplegarTransbordos()
        
    // 🔍 === [MÓDULO 6: FILTRAR CATÁLOGO (OPERATIVIDAD Y ACCESIBILIDAD)] ===
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
        
    // 🔍 === [MÓDULO 7: MODO ADMINISTRADOR (CREAR/INSERTAR ESTACIÓN O LÍNEA)] ===
    case "7":
        print("\n==========================================")
        print("🛠️ MODO ADMINISTRADOR - GESTIÓN DE RED".negrita.cian)
        print("==========================================")
        print("1. Insertar nueva estación en una línea (Posición personalizada)")
        print("2. Registrar una línea completamente nueva")
        print("3. Volver al menú principal")
        print("Seleccione una opción:")
        
        let subOpAdmin = readLine() ?? ""
        switch subOpAdmin {
        case "1":
            print("\n¿En qué línea deseas colocar la nueva estación?:")
            for (i, l) in redCentral.lineasRed.enumerated() {
                print("\(i + 1). \(l.denominacion) (Total actual: \(l.paraderos.count) estaciones)")
            }
            if let numL = Int(readLine() ?? "") {
                print("¿En qué número de posición deseas colocarla?")
                print("(Ejemplo: Ingresa 15 para colocarla entre Arriola y Gamarra en Línea 1)")
                
                if let posIngresada = Int(readLine() ?? "") {
                    print("Nombre de la nueva estación:")
                    let nomEstacion = readLine() ?? ""
                    print("Cruce de avenidas / Ubicación:")
                    let cruce = readLine() ?? ""
                    
                    let res = redCentral.insertarEstacion(numLinea: numL, posicion: posIngresada, nombreEstacion: nomEstacion, cruce: cruce)
                    if res.exito {
                        print("\n✅ ¡Estación '\(nomEstacion)' insertada con éxito en la posición \(posIngresada) de la \(res.lineaNombre)!".verde.negrita)
                        print("• Heredó la tarifa oficial de la línea: S/ \(String(format: "%.2f", res.tarifa))".amarillo)
                    } else {
                        print("\n❌ Selección de línea no válida.".rojo)
                    }
                } else {
                    print("❌ Posición numérica no válida.".rojo)
                }
            }
            
        case "2":
            print("\nNombre de la nueva línea (Ej: Linea 3):")
            let nom = readLine() ?? ""
            print("Color identificador (Ej: Azul):")
            let col = readLine() ?? ""
            print("Tarifa General / Adulto (S/):")
            let tAdulto = Double(readLine() ?? "") ?? 1.50
            print("Tarifa Medio Pasaje (S/):")
            let tMedio = Double(readLine() ?? "") ?? 0.75
            
            redCentral.crearNuevaLinea(denominacion: nom, color: col, tarifaAdulto: tAdulto, tarifaMedio: tMedio)
            print("\n✅ ¡Línea '\(nom)' creada e integrada a la red!".verde.negrita)
            
        default:
            print("Volviendo al menú principal...")
        }
        
    // 🔍 === [MÓDULO 8: VER LEYENDA TÉCNICA Y SIMBOLOGÍA] ===
    case "8":
        imprimirLeyendaSistema()
        
    // 🔍 === [MÓDULO 9: SALIR DEL SISTEMA] ===
    case "9":
        sistemaActivo = false
        print("\nCerrando el sistema de transporte. ¡Éxitos, Calep!".verde.negrita)
        
    default:
        print("❌ Opción inválida. Intente de nuevo.".rojo)
    }
}
