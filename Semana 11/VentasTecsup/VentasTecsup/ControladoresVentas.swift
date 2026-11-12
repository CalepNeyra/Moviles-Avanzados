import UIKit

class ControladorVentas: UIViewController {
    var repositorio: RepositorioVentas {
        get throws {
            guard let app = UIApplication.shared.delegate as? AppDelegate else {
                throw ErrorVentas.modeloNoDisponible
            }
            return try app.repositorio.get()
        }
    }
}

final class IngresoViewController: ControladorVentas {
    func ingresar(usuario: String, clave: String) throws -> Usuario {
        try repositorio.iniciarSesion(usuario: usuario, clave: clave)
    }
}

final class RegistroViewController: ControladorVentas {
    func usuarioDisponible(_ usuario: String) throws -> Bool {
        try repositorio.usuarioDisponible(usuario)
    }

    func crearCuenta(nombre: String, usuario: String, clave: String, confirmacion: String, rol: Rol) throws -> Usuario {
        try repositorio.registrar(nombre: nombre, usuario: usuario, clave: clave, confirmacion: confirmacion, rol: rol)
    }
}

final class ProductosViewController: ControladorVentas {
    func listar(busqueda: String = "", categoria: String? = nil) throws -> [Producto] {
        try repositorio.productos(busqueda: busqueda, categoria: categoria)
    }

    func categorias() throws -> [String] {
        let productos = try repositorio.productos()
        return Set(productos.map(\.categoria)).sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }

    func guardar(_ producto: Producto? = nil, nombre: String, categoria: String, precio: Decimal, stock: Int64) throws -> Producto {
        try repositorio.guardarProducto(producto, nombre: nombre, categoria: categoria, precio: precio, stock: stock)
    }

    func eliminar(_ producto: Producto) throws {
        try repositorio.eliminarProducto(producto)
    }
}

struct FilaCliente {
    let cliente: Cliente
    let totalComprado: Decimal
    let categoria: CategoriaCliente
}

final class ClientesViewController: ControladorVentas {
    func listar(busqueda: String = "") throws -> [FilaCliente] {
        let repositorio = try repositorio
        return try repositorio.clientes(busqueda: busqueda).map { cliente in
            let perfil = try repositorio.perfilCompras(cliente)
            return FilaCliente(cliente: cliente, totalComprado: perfil.total, categoria: perfil.categoria)
        }
    }

    func guardar(_ cliente: Cliente? = nil, nombre: String, documento: String) throws -> Cliente {
        try repositorio.guardarCliente(cliente, nombre: nombre, documento: documento)
    }

    func eliminar(_ cliente: Cliente) throws {
        try repositorio.eliminarCliente(cliente)
    }
}

final class NuevaVentaViewController: ControladorVentas {
    func vendedor() throws -> Usuario {
        try repositorio.exigirSesion(.vendedor)
    }

    func productos(busqueda: String = "") throws -> [Producto] {
        try repositorio.productos(busqueda: busqueda)
    }

    func clientes(busqueda: String = "") throws -> [Cliente] {
        try repositorio.clientes(busqueda: busqueda)
    }

    func cotizar(producto: Producto, cliente: Cliente, cantidad: Int64) throws -> ImportesVenta {
        try repositorio.cotizar(producto: producto, cliente: cliente, cantidad: cantidad)
    }

    func registrar(producto: Producto, cliente: Cliente, cantidad: Int64) throws -> Venta {
        try repositorio.registrarVenta(producto: producto, cliente: cliente, cantidad: cantidad)
    }
}

final class MisVentasViewController: ControladorVentas {
    func listar(periodo: PeriodoVentas = .todas, cliente: String = "") throws -> [Venta] {
        try repositorio.misVentas(periodo: periodo, cliente: cliente)
    }

    func indicadores() throws -> IndicadoresVentas {
        try repositorio.indicadoresPersonales()
    }
}

final class VentasEquipoViewController: ControladorVentas {
    func vendedores() throws -> [Usuario] {
        try repositorio.vendedores()
    }

    func listar(periodo: PeriodoVentas = .todas, vendedor: Usuario? = nil, cliente: String = "") throws -> [Venta] {
        try repositorio.ventasEquipo(periodo: periodo, vendedor: vendedor, cliente: cliente)
    }
}

final class AnularVentaViewController: ControladorVentas {
    func confirmar(venta: Venta, motivo: String) throws {
        try repositorio.anularVenta(venta, motivo: motivo)
    }
}

final class ResumenSupervisorViewController: ControladorVentas {
    func resumen() throws -> ResumenSupervisor {
        try repositorio.resumenSupervisor()
    }
}

enum PestanaVentas {
    case resumen, ventasEquipo, productos, clientes, nuevaVenta, misVentas, cuenta

    static func para(_ rol: Rol) -> [PestanaVentas] {
        switch rol {
        case .vendedor: return [.productos, .clientes, .nuevaVenta, .misVentas, .cuenta]
        case .supervisor: return [.resumen, .ventasEquipo, .productos, .clientes, .cuenta]
        }
    }
}

final class CuentaViewController: ControladorVentas {
    func cuentaActual() throws -> Usuario {
        try repositorio.exigirSesion()
    }

    func cerrarSesion() throws {
        try repositorio.cerrarSesion()
    }
}
