import CoreData
import Foundation

@MainActor
final class RepositorioVentas {
    private let contenedor: NSPersistentContainer
    private var contexto: NSManagedObjectContext { contenedor.viewContext }
    private(set) var usuarioActual: Usuario?

    static func abrir(enMemoria: Bool = false) throws -> RepositorioVentas {
        guard let urlModelo = Bundle.main.url(forResource: "VentasTecsup", withExtension: "momd"),
              let modelo = NSManagedObjectModel(contentsOf: urlModelo) else {
            throw ErrorVentas.modeloNoDisponible
        }

        let contenedor = NSPersistentContainer(name: "VentasTecsup", managedObjectModel: modelo)
        let directorio = NSPersistentContainer.defaultDirectoryURL()
        if !enMemoria {
            try FileManager.default.createDirectory(at: directorio, withIntermediateDirectories: true)
        }

        try contenedor.persistentStoreCoordinator.addPersistentStore(
            ofType: enMemoria ? NSInMemoryStoreType : NSSQLiteStoreType,
            configurationName: nil,
            at: enMemoria ? nil : directorio.appendingPathComponent("VentasTecsup.sqlite"),
            options: [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
            ]
        )
        return RepositorioVentas(contenedor: contenedor)
    }

    private init(contenedor: NSPersistentContainer) {
        self.contenedor = contenedor
        contenedor.viewContext.undoManager = nil
    }

    func usuarioDisponible(_ usuario: String) throws -> Bool {
        let normalizado = ReglasVentas.normalizarUsuario(usuario)
        guard !normalizado.isEmpty else { return false }
        return try buscarUsuario(normalizado) == nil
    }

    @discardableResult
    func registrar(nombre: String, usuario: String, clave: String, confirmacion: String, rol: Rol) throws -> Usuario {
        let nombre = try obligatorio(nombre)
        let usuario = try obligatorio(ReglasVentas.normalizarUsuario(usuario))
        guard clave.count >= 6 else { throw ErrorVentas.claveCorta }
        guard clave == confirmacion else { throw ErrorVentas.clavesDistintas }
        guard try buscarUsuario(usuario) == nil else { throw ErrorVentas.usuarioOcupado }

        let claveProtegida = try Credenciales.codificar(clave)
        let cuenta = Usuario(context: contexto)
        cuenta.nombre = nombre
        cuenta.usuario = usuario
        cuenta.clave = claveProtegida
        cuenta.rol = rol.rawValue
        try guardar()
        usuarioActual = cuenta
        return cuenta
    }

    @discardableResult
    func iniciarSesion(usuario: String, clave: String) throws -> Usuario {
        guard let cuenta = try buscarUsuario(ReglasVentas.normalizarUsuario(usuario)),
              Rol(rawValue: cuenta.rol) != nil,
              try Credenciales.verifica(clave, contra: cuenta.clave) else {
            throw ErrorVentas.credencialesInvalidas
        }
        usuarioActual = cuenta
        return cuenta
    }

    func cerrarSesion() {
        usuarioActual = nil
    }

    func exigirSesion(_ rol: Rol? = nil) throws -> Usuario {
        guard let usuarioActual else { throw ErrorVentas.sinSesion }
        guard let rolActual = Rol(rawValue: usuarioActual.rol), rol == nil || rolActual == rol else {
            throw ErrorVentas.permisoDenegado
        }
        return usuarioActual
    }

    func productos(busqueda: String = "", categoria: String? = nil) throws -> [Producto] {
        _ = try exigirSesion()
        var filtros: [NSPredicate] = []
        let busqueda = limpiar(busqueda)
        if !busqueda.isEmpty {
            filtros.append(NSPredicate(format: "nombre CONTAINS[cd] %@", busqueda))
        }
        if let categoria {
            filtros.append(NSPredicate(format: "categoria ==[cd] %@", categoria))
        }
        return try consultar(Producto.self, filtros: filtros, orden: [NSSortDescriptor(key: "nombre", ascending: true)])
    }

    @discardableResult
    func guardarProducto(_ producto: Producto? = nil, nombre: String, categoria: String, precio: Decimal, stock: Int64) throws -> Producto {
        _ = try exigirSesion(.supervisor)
        let nombre = try obligatorio(nombre)
        let categoria = try obligatorio(categoria)
        guard !precio.isNaN, precio > 0, ReglasVentas.redondear(precio) == precio else {
            throw ErrorVentas.precioInvalido
        }
        let precioGuardado = try convertirImporte(precio)
        guard stock >= 0 else { throw ErrorVentas.stockInvalido }
        if let producto { try verificar(producto) }

        let registro = producto ?? Producto(context: contexto)
        registro.nombre = nombre
        registro.categoria = categoria
        registro.precio = precioGuardado
        registro.stock = stock
        try guardar()
        return registro
    }

    func eliminarProducto(_ producto: Producto) throws {
        _ = try exigirSesion(.supervisor)
        try eliminar(producto, tieneVentas: producto.ventas?.count ?? 0)
    }

    func clientes(busqueda: String = "") throws -> [Cliente] {
        _ = try exigirSesion()
        let busqueda = limpiar(busqueda)
        let filtros = busqueda.isEmpty ? [] : [
            NSPredicate(format: "nombre CONTAINS[cd] %@ OR documento CONTAINS[cd] %@", busqueda, busqueda)
        ]
        return try consultar(Cliente.self, filtros: filtros, orden: [NSSortDescriptor(key: "nombre", ascending: true)])
    }

    @discardableResult
    func guardarCliente(_ cliente: Cliente? = nil, nombre: String, documento: String) throws -> Cliente {
        _ = try exigirSesion()
        let nombre = try obligatorio(nombre)
        let documento = try obligatorio(documento)
        if let cliente { try verificar(cliente) }

        let registro = cliente ?? Cliente(context: contexto)
        registro.nombre = nombre
        registro.documento = documento
        try guardar()
        return registro
    }

    func eliminarCliente(_ cliente: Cliente) throws {
        _ = try exigirSesion(.supervisor)
        try eliminar(cliente, tieneVentas: cliente.ventas?.count ?? 0)
    }

    func perfilCompras(_ cliente: Cliente) throws -> (total: Decimal, categoria: CategoriaCliente) {
        _ = try exigirSesion()
        try verificar(cliente)
        let compras = try consultar(Venta.self, filtros: [
            NSPredicate(format: "cliente == %@ AND anulada == NO", argumentArray: [cliente])
        ])
        let total = compras.reduce(Decimal.zero) { $0 + importe($1.total) }
        return (total, ReglasVentas.categoria(totalComprado: total))
    }

    func cotizar(producto: Producto, cliente: Cliente, cantidad: Int64) throws -> ImportesVenta {
        _ = try exigirSesion(.vendedor)
        try verificar(producto)
        guard cantidad > 0 else { throw ErrorVentas.cantidadInvalida }
        guard cantidad <= producto.stock else { throw ErrorVentas.stockInsuficiente(disponible: producto.stock) }

        let perfil = try perfilCompras(cliente)
        let calculo = ReglasVentas.calcular(precioUnitario: importe(producto.precio), cantidad: cantidad, categoria: perfil.categoria)
        _ = try convertirImporte(calculo.total)
        return calculo
    }

    @discardableResult
    func registrarVenta(producto: Producto, cliente: Cliente, cantidad: Int64, fecha: Date = Date()) throws -> Venta {
        let vendedor = try exigirSesion(.vendedor)
        let calculo = try cotizar(producto: producto, cliente: cliente, cantidad: cantidad)
        let descuento = try convertirImporte(calculo.descuento)
        let igv = try convertirImporte(calculo.igv)
        let total = try convertirImporte(calculo.total)

        let venta = Venta(context: contexto)
        venta.fecha = fecha
        venta.cantidad = cantidad
        venta.precioUnitario = producto.precio
        venta.descuento = descuento
        venta.igv = igv
        venta.total = total
        venta.anulada = false
        venta.vendedor = vendedor
        venta.producto = producto
        venta.cliente = cliente
        producto.stock -= cantidad
        try guardar()
        return venta
    }

    func anularVenta(_ venta: Venta, motivo: String) throws {
        _ = try exigirSesion(.supervisor)
        try verificar(venta)
        guard !venta.anulada else { throw ErrorVentas.ventaAnulada }

        let motivo = limpiar(motivo)
        guard !motivo.isEmpty else { throw ErrorVentas.motivoRequerido }
        let (stock, desborda) = venta.producto.stock.addingReportingOverflow(venta.cantidad)
        guard !desborda else { throw ErrorVentas.stockInvalido }

        venta.producto.stock = stock
        venta.motivoAnulacion = motivo
        venta.anulada = true
        try guardar()
    }

    func consultar<T: NSManagedObject>(_ tipo: T.Type, filtros: [NSPredicate] = [], orden: [NSSortDescriptor] = [], limite: Int = 0) throws -> [T] {
        let solicitud = NSFetchRequest<T>(entityName: String(describing: tipo))
        if !filtros.isEmpty {
            solicitud.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: filtros)
        }
        solicitud.sortDescriptors = orden
        solicitud.fetchLimit = limite
        return try contexto.fetch(solicitud)
    }

    func verificar(_ registro: NSManagedObject) throws {
        guard registro.managedObjectContext === contexto, !registro.isDeleted else {
            throw ErrorVentas.objetoNoDisponible
        }
    }

    func limpiar(_ texto: String) -> String {
        texto.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func importe(_ almacenado: Double) -> Decimal {
        Decimal(string: String(almacenado), locale: Locale(identifier: "en_US_POSIX")) ?? .nan
    }

    private func buscarUsuario(_ usuario: String) throws -> Usuario? {
        try consultar(Usuario.self, filtros: [NSPredicate(format: "usuario == %@", usuario)], limite: 1).first
    }

    private func obligatorio(_ texto: String) throws -> String {
        let texto = limpiar(texto)
        guard !texto.isEmpty else { throw ErrorVentas.camposRequeridos }
        return texto
    }

    private func convertirImporte(_ monto: Decimal) throws -> Double {
        guard !monto.isNaN else { throw ErrorVentas.precioInvalido }
        let almacenado = NSDecimalNumber(decimal: monto).doubleValue
        guard almacenado.isFinite, importe(almacenado) == monto else { throw ErrorVentas.precioInvalido }
        return almacenado
    }

    private func eliminar(_ registro: NSManagedObject, tieneVentas: @autoclosure () -> Int) throws {
        try verificar(registro)
        guard tieneVentas() == 0 else { throw ErrorVentas.tieneVentas }
        contexto.delete(registro)
        try guardar()
    }

    private func guardar() throws {
        do {
            try contexto.save()
        } catch {
            contexto.rollback()
            throw error
        }
    }
}
