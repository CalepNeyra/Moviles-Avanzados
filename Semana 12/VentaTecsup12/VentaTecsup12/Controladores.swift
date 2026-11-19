import UIKit
import CoreData

class ControladorVentas: UIViewController {
    var repositorio: RepositorioVentas {
        get throws {
            guard let app = UIApplication.shared.delegate as? AppDelegate else {
                throw ErrorVentas.modeloNoDisponible
            }
            return try app.almacen.get()
        }
    }
}

final class IngresoViewController: ControladorVentas {

    @IBOutlet private weak var logo: UIImageView!
    @IBOutlet private weak var hero: UILabel!
    @IBOutlet private weak var subtitulo: UILabel!
    @IBOutlet private weak var usuario: UITextField!
    @IBOutlet private weak var clave: UITextField!
    @IBOutlet private weak var aviso: UILabel!
    @IBOutlet private weak var entrar: UIButton!
    @IBOutlet private weak var registro: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        logo.tintColor = .white
        logo.backgroundColor = .azulMaqueta
        logo.layer.cornerRadius = 22
        logo.contentMode = .center
        logo.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 41, weight: .regular)
        navigationController?.view.tintColor = .azulMaqueta
        subtitulo.textColor = .secondaryLabel
        entrar.aplicarBotonPrincipal()
        var enlace = AttributedString("¿Primera vez? ")
        enlace.foregroundColor = .secondaryLabel
        var accion = AttributedString("Crear cuenta")
        accion.foregroundColor = .azulMaqueta
        accion.font = .boldSystemFont(ofSize: 15)
        enlace += accion
        registro.configuration?.attributedTitle = enlace
        aviso.textColor = .systemRed
        aviso.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @IBAction private func entrarTocado(_ sender: UIButton) {
        view.endEditing(true)
        do {
            mostrarSesion(try repositorio.acceder(usuario: usuario.text ?? "", clave: clave.text ?? ""))
        } catch {
            aviso.text = error.localizedDescription
            aviso.isHidden = false
        }
    }

    @IBAction private func registroTocado(_ sender: UIButton) {
        guard let escena = storyboard?.instantiateViewController(withIdentifier: "A2") else { return }
        navigationController?.pushViewController(escena, animated: true)
    }

}

final class RegistroViewController: ControladorVentas {

    @IBOutlet private weak var nombre: UITextField!
    @IBOutlet private weak var usuario: UITextField!
    @IBOutlet private weak var clave: UITextField!
    @IBOutlet private weak var repetir: UITextField!
    @IBOutlet private weak var rol: UISegmentedControl!
    @IBOutlet private weak var aviso: UILabel!
    @IBOutlet private weak var guardar: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        aviso.isHidden = true
        aviso.textAlignment = .right
        guardar.aplicarBotonPrincipal()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @IBAction private func actualizar(_ sender: UIControl) {
        let texto = usuario.text ?? ""
        aviso.isHidden = ReglasVentas.normalizarUsuario(texto).isEmpty
        guard !aviso.isHidden else { return }
        ejecutar {
            let disponible = try repositorio.disponible(texto)
            aviso.text = disponible ? "✓ Disponible" : "El usuario ya existe."
            aviso.textColor = disponible ? .systemGreen : .systemRed
        }
    }

    @IBAction private func guardarTocado(_ sender: UIButton) {
        view.endEditing(true)
        ejecutar {
            let rolElegido: Rol = rol.selectedSegmentIndex == 1 ? .supervisor : .vendedor
            let cuenta = try repositorio.registrarUsuario(nombre: nombre.text ?? "", usuario: usuario.text ?? "",
                                                          clave: clave.text ?? "", confirmacion: repetir.text ?? "",
                                                          rol: rolElegido)
            mostrarSesion(cuenta)
        }
    }

}

final class ProductosViewController: ControladorListaVentas {
    override var notaLista: String? { esSupervisor ? "Vista del supervisor. El vendedor solo consulta: sin “+” y sin borrar." : nil }


    @IBOutlet private weak var buscar: UITextField!
    @IBOutlet private weak var filtros: UIScrollView!
    private var categoria: String?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = esSupervisor
            ? UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(nuevo)) : nil
        ejecutar { try self.recargarCategorias() }
        actualizar(buscar)
    }

    private func recargarCategorias() throws {
        let opciones = Array(Set(try repositorio.productos().map(\.categoria))).sorted()
        if let categoria, !opciones.contains(categoria) { self.categoria = nil }
        chips(filtros, titulos: ["Todos"] + opciones, seleccion: categoria.flatMap { opciones.firstIndex(of: $0) }.map { $0 + 1 } ?? 0) { [weak self] indice in
            guard let self else { return }
            categoria = indice == 0 ? nil : opciones[indice - 1]
            ejecutar { try self.recargarCategorias() }
            actualizar(buscar)
        }
    }

    @IBAction private func actualizar(_ sender: UIControl) {
        ejecutar {
            let supervisor = esSupervisor
            filas = try repositorio.productos(busqueda: buscar.text ?? "", categoria: categoria).map { producto in
                var fila = FilaVentas(titulo: producto.nombre, subtitulo: producto.categoria,
                                      valor: dinero(producto.precio),
                                      icono: iniciales(producto.nombre), color: colorCategoria(producto.categoria),
                                      distintivo: "\(producto.stock) u.", colorDistintivo: producto.colorStock)
                if supervisor {
                    fila.tocar = { [weak self] in self?.editar(producto) }
                    fila.accion = "Borrar"
                    fila.deslizar = { [weak self] in
                        self?.confirmarBorrado(producto.nombre) {
                            guard let self else { return }
                            try self.repositorio.borrarProducto(producto)
                            try self.recargarCategorias()
                            self.actualizar(self.buscar)
                        }
                    }
                }
                return fila
            }
        }
    }

    @objc private func nuevo() { editar(nil) }

    private func editar(_ producto: Producto?) {
        let titulo = producto == nil ? "Nuevo producto" : "Editar producto"
        formulario(titulo, campos: [
            ("Nombre", producto?.nombre, .default), ("Categoría", producto?.categoria, .default),
            ("Precio", producto.map { String($0.precio) }, .decimalPad),
            ("Stock", producto.map { String($0.stock) }, .numberPad)
        ]) { [weak self] textos in
            guard let self else { return }
            let precioTexto = textos[2].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
            guard precioTexto.range(of: #"^[0-9]+(\.[0-9]{1,2})?$"#, options: .regularExpression) != nil,
                  let precio = Decimal(string: precioTexto, locale: Locale(identifier: "en_US_POSIX")) else {
                throw ErrorVentas.precioInvalido
            }
            guard let stock = Int64(textos[3]) else { throw ErrorVentas.stockInvalido }
            _ = try repositorio.guardarProducto(producto, nombre: textos[0], categoria: textos[1], precio: precio, stock: stock)
            try recargarCategorias()
            actualizar(buscar)
        }
    }

}

struct FilaCliente {
    let cliente: Cliente
    let totalComprado: Decimal
    let categoria: CategoriaCliente
}

final class ClientesViewController: ControladorListaVentas {
    override var notaLista: String? { "Categoría y “comprado” se calculan con las ventas no anuladas; no se guardan." }


    @IBOutlet private weak var buscar: UITextField!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(nuevo))
        actualizar(buscar)
    }

    @IBAction private func actualizar(_ sender: UIControl) {
        ejecutar {
            filas = try repositorio.perfiles(busqueda: buscar.text ?? "").map { item in
                let cliente = item.cliente
                let color: UIColor
                switch item.categoria {
                case .vip: color = .systemPurple
                case .frecuente: color = .systemBlue
                case .regular: color = .systemGray
                }
                var fila = FilaVentas(titulo: cliente.nombre, subtitulo: cliente.documento,
                                      valor: dinero(item.totalComprado),
                                      icono: iniciales(cliente.nombre), color: color,
                                      distintivo: item.categoria.rawValue, colorDistintivo: color, comprado: true)
                fila.tocar = { [weak self] in self?.editar(cliente) }
                if esSupervisor {
                    fila.accion = "Borrar"
                    fila.deslizar = { [weak self] in
                        self?.confirmarBorrado(cliente.nombre) {
                            guard let self else { return }
                            try self.repositorio.borrarCliente(cliente)
                            self.actualizar(self.buscar)
                        }
                    }
                }
                return fila
            }
        }
    }

    @objc private func nuevo() { editar(nil) }

    private func editar(_ cliente: Cliente?) {
        formulario(cliente == nil ? "Nuevo cliente" : "Editar cliente", campos: [
            ("Nombre", cliente?.nombre, .default), ("Documento", cliente?.documento, .default)
        ]) { [weak self] textos in
            guard let self else { return }
            _ = try repositorio.guardarCliente(cliente, nombre: textos[0], documento: textos[1])
            actualizar(buscar)
        }
    }

}

final class NuevaVentaViewController: ControladorVentas {

    @IBOutlet private weak var vendedorLabel: UILabel!
    @IBOutlet private weak var vendedorIniciales: UILabel!
    @IBOutlet private weak var productoBoton: UIButton!
    @IBOutlet private weak var clienteBoton: UIButton!
    @IBOutlet private weak var cantidadLabel: UILabel!
    @IBOutlet private weak var cantidad: UIStepper!
    @IBOutlet private weak var subtotalValor: UILabel!
    @IBOutlet private weak var descuentoTitulo: UILabel!
    @IBOutlet private weak var descuentoValor: UILabel!
    @IBOutlet private weak var igvValor: UILabel!
    @IBOutlet private weak var totalValor: UILabel!
    @IBOutlet private weak var aviso: UILabel!
    @IBOutlet private weak var guardar: UIButton!
    private var producto: Producto?
    private var cliente: Cliente?

    override func viewDidLoad() {
        super.viewDidLoad()
        guardar.aplicarBotonPrincipal()
        vendedorLabel.textColor = .azulMaqueta
        vendedorIniciales.textAlignment = .center
        vendedorIniciales.textColor = .white
        vendedorIniciales.backgroundColor = .azulMaqueta
        vendedorIniciales.layer.cornerRadius = 10
        vendedorIniciales.clipsToBounds = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ejecutar {
            let vendedor = try repositorio.exigirSesion(.vendedor)
            vendedorLabel.text = "\(vendedor.nombre) · Vendedor\nSesión iniciada · la venta se registra a tu nombre"
            vendedorIniciales.text = iniciales(vendedor.nombre)
            actualizar(cantidad)
        }
    }

    @IBAction private func productoBotonTocado(_ sender: UIButton) {
        elegir(titulo: "Elegir producto", consultar: { [weak self] texto in
            try self?.repositorio.productos(busqueda: texto) ?? []
        }, nombrar: { "\($0.nombre) · \($0.stock) u." }) { [weak self] producto in
            guard let self else { return }
            self.producto = producto
            cantidad.value = 1
            actualizar(cantidad)
        }
    }

    @IBAction private func clienteBotonTocado(_ sender: UIButton) {
        elegir(titulo: "Elegir cliente", consultar: { [weak self] texto in
            try self?.repositorio.clientes(busqueda: texto) ?? []
        }, nombrar: { "\($0.nombre) · \($0.documento)" }) { [weak self] cliente in
            guard let self else { return }
            self.cliente = cliente
            actualizar(cantidad)
        }
    }

    private func elegir<T>(titulo: String, consultar: @escaping (String) throws -> [T],
                           nombrar: @escaping (T) -> String, elegir: @escaping (T) -> Void) {
        let pantalla = SelectorVentasViewController()
        pantalla.title = titulo
        pantalla.buscar = { texto in
            try consultar(texto).map { item in (nombrar(item), { elegir(item) }) }
        }
        navigationController?.pushViewController(pantalla, animated: true)
    }

    @IBAction private func actualizar(_ sender: UIControl) {
        if producto?.isDeleted == true || producto?.managedObjectContext == nil { producto = nil }
        if cliente?.isDeleted == true || cliente?.managedObjectContext == nil { cliente = nil }
        actualizarSelector(productoBoton, valor: producto?.nombre ?? "Elegir producto")
        actualizarSelector(clienteBoton, valor: cliente?.nombre ?? "Elegir cliente")
        let unidades = Int64(cantidad.value)
        cantidadLabel.text = "Cantidad" + (producto.map { " (stock \($0.stock))" } ?? "") + " · \(unidades)"
        guardar.isEnabled = producto != nil && cliente != nil
        descuentoTitulo.text = "Descuento"
        for valor in [subtotalValor, descuentoValor, igvValor, totalValor] {
            valor?.text = "—"
            valor?.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        aviso.isHidden = true
        guard let producto, let cliente else { return }
        do {
            let importe = try repositorio.cotizar(producto: producto, cliente: cliente, cantidad: unidades)
            subtotalValor.text = dinero(importe.subtotal)
            descuentoTitulo.text = importe.categoria == .vip ? "Descuento VIP 10%" : "Descuento"
            descuentoValor.text = importe.descuento > 0 ? "− " + dinero(importe.descuento) : dinero(importe.descuento)
            igvValor.text = dinero(importe.igv)
            totalValor.text = dinero(importe.total)
        } catch {
            aviso.text = error.localizedDescription
            aviso.isHidden = false
        }
    }

    private func actualizarSelector(_ boton: UIButton, valor: String) {
        var config = UIButton.Configuration.plain()
        config.title = valor
        config.image = UIImage(systemName: "chevron.right")
        config.imagePlacement = .trailing
        config.imagePadding = 6
        config.baseForegroundColor = .secondaryLabel
        config.contentInsets = .zero
        boton.contentHorizontalAlignment = .trailing
        boton.configuration = config
    }

    @IBAction private func guardarTocado(_ sender: UIButton) {
        guard let producto, let cliente else { return }
        ejecutar {
            let venta = try repositorio.vender(producto: producto, cliente: cliente, cantidad: Int64(cantidad.value))
            self.producto = nil
            self.cliente = nil
            cantidad.value = 1
            actualizar(cantidad)
            mensaje("Venta registrada", dinero(venta.total))
        }
    }

}

final class MisVentasViewController: ControladorListaVentas {
    override var notaLista: String? { "Solo aparecen las ventas de este vendedor." }


    @IBOutlet private weak var tarjetas: UIStackView!
    @IBOutlet private weak var periodo: UISegmentedControl!
    @IBOutlet private weak var buscar: UITextField!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let cuenta = try? repositorio.exigirSesion() {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                customView: etiqueta(iniciales(cuenta.nombre), .subheadline, color: .azulMaqueta)
            )
        }
        actualizar(buscar)
    }

    @IBAction private func actualizar(_ sender: UIControl) {
        ejecutar {
            let datos = try repositorio.indicadores()
            tarjetas.vaciar()
            tarjetas.distribution = .fillEqually
            tarjetas.addArrangedSubview(tarjeta("Hoy", dinero(datos.totalHoy), "\(datos.cantidadHoy) ventas"))
            tarjetas.addArrangedSubview(tarjeta("Mes", dinero(datos.totalMes), "\(datos.cantidadMes) ventas"))
            filas = try repositorio.misVentas(periodo: periodo.periodoVenta, cliente: buscar.text ?? "").map { venta in
                var fila = filaVenta(venta)
                fila.tocar = { [weak self] in
                    self?.mensaje(venta.cliente.nombre, detalleVenta(venta))
                }
                return fila
            }
        }
    }

}

final class VentasEquipoViewController: ControladorListaVentas {
    override var notaLista: String? { "El nombre del vendedor se lee de la relación venta ▸ vendedor." }


    @IBOutlet private weak var periodo: UISegmentedControl!
    @IBOutlet private weak var filtros: UIScrollView!
    @IBOutlet private weak var buscar: UITextField!
    private var filtroVendedor: Usuario?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let cuenta = try? repositorio.exigirSesion() {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                customView: etiqueta(iniciales(cuenta.nombre), .subheadline, color: .azulMaqueta)
            )
        }
        ejecutar { try self.recargarVendedores() }
        actualizar(buscar)
    }

    private func recargarVendedores() throws {
        let opciones = try repositorio.vendedores()
        chips(filtros, titulos: ["Todos"] + opciones.map(\.nombre),
              seleccion: filtroVendedor.flatMap { opciones.firstIndex(of: $0) }.map { $0 + 1 } ?? 0) { [weak self] indice in
            guard let self else { return }
            filtroVendedor = indice == 0 ? nil : opciones[indice - 1]
            ejecutar { try self.recargarVendedores() }
            actualizar(buscar)
        }
    }

    @IBAction private func actualizar(_ sender: UIControl) {
        ejecutar {
            filas = try repositorio.ventasEquipo(periodo: periodo.periodoVenta, vendedor: filtroVendedor, cliente: buscar.text ?? "").map { venta in
                var fila = filaVenta(venta, incluirVendedor: true)
                if !venta.anulada {
                    fila.accion = "Anular"
                    fila.deslizar = { [weak self] in
                        guard let self, let escena = storyboard?.instantiateViewController(withIdentifier: "A8") as? AnularVentaViewController else { return }
                        escena.venta = venta
                        escena.alConfirmar = { [weak self] in
                            guard let self else { return }
                            self.actualizar(self.buscar)
                        }
                        escena.modalPresentationStyle = .overFullScreen
                        escena.modalTransitionStyle = .crossDissolve
                        present(escena, animated: true)
                    }
                }
                return fila
            }
        }
    }

}

final class AnularVentaViewController: ControladorVentas {

    @IBOutlet private weak var panel: UIStackView!
    @IBOutlet private weak var detalle: UILabel!
    @IBOutlet private weak var motivo: UITextField!
    @IBOutlet private weak var guardar: UIButton!
    @IBOutlet private weak var cancelar: UIButton!
    var venta: Venta?
    var alConfirmar: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        panel.layer.cornerRadius = 17
        panel.clipsToBounds = true
        detalle.textColor = .secondaryLabel
        guardar.tintColor = .systemRed
        guardar.configuration?.baseForegroundColor = .systemRed
        cancelar.configuration?.baseForegroundColor = .label
        NSLayoutConstraint.activate([
            panel.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            panel.bottomAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor, constant: -12)
        ])
        if let venta {
            detalle.text = "\(venta.cliente.nombre) · \(venta.producto.nombre) × \(venta.cantidad)\n\(dinero(venta.total))\nEl stock se devolverá (+\(venta.cantidad))."
        }
        actualizar(motivo)
    }

    @IBAction private func actualizar(_ sender: UIControl) {
        guardar.isEnabled = venta != nil && !(motivo.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @IBAction private func guardarTocado(_ sender: UIButton) {
        guard let venta else { return }
        ejecutar {
            try repositorio.anular(venta, motivo: motivo.text ?? "")
            dismiss(animated: true, completion: alConfirmar)
        }
    }

    @IBAction private func cancelarTocado(_ sender: UIButton) { dismiss(animated: true) }

}

final class ResumenSupervisorViewController: ControladorVentas {

    @IBOutlet private weak var lista: UIStackView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recargar()
    }

    private func recargar() {
        ejecutar {
            let cuenta = try repositorio.exigirSesion(.supervisor)
            let datos = try repositorio.resumen()
            lista.vaciar()
            lista.addArrangedSubview(saludo(cuenta))

            let variacion = datos.variacionRespectoAyer
            let vendido = tarjeta("Vendido hoy", dinero(datos.totalHoy))
            if let variacion {
                let incremento = variacion >= 0
                let cambio = etiqueta("\(incremento ? "▲" : "▼") \(abs(variacion))% vs ayer",
                                      .caption1, color: incremento ? .systemGreen : .systemRed)
                vendido.addArrangedSubview(cambio)
            }
            let metricas = UIStackView(arrangedSubviews: [vendido, tarjeta("IGV del mes", dinero(datos.igvMes))])
            metricas.spacing = 10
            metricas.distribution = .fillEqually
            lista.addArrangedSubview(metricas)
            lista.addArrangedSubview(grafico(datos.ultimosSieteDias))
            lista.addArrangedSubview(ranking(datos.rankingVendedores))
            lista.addArrangedSubview(stock(datos.stockBajo))
        }
    }

    private func saludo(_ cuenta: Usuario) -> UIView {
        let fecha = Date().formatted(.dateTime.weekday(.wide).day().month(.wide).locale(Locale(identifier: "es_PE")))
        let nombre = cuenta.nombre.split(whereSeparator: \.isWhitespace).first.map(String.init) ?? cuenta.nombre
        let titulo = UIStackView(arrangedSubviews: [
            etiqueta(fecha.prefix(1).uppercased() + String(fecha.dropFirst()), .subheadline, color: .secondaryLabel),
            etiqueta("Hola, \(nombre)", .title1)
        ])
        titulo.axis = .vertical
        let rol = insignia(cuenta.rol, color: .systemPurple)
        let fila = UIStackView(arrangedSubviews: [titulo, rol])
        fila.alignment = .top
        fila.spacing = 8
        fila.isLayoutMarginsRelativeArrangement = true
        fila.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 2, leading: 7, bottom: 0, trailing: 7)
        return fila
    }

    private func ranking(_ vendedores: [TotalVendedor]) -> UIView {
        let panel = tarjeta("Ranking de vendedores (mes)", nil)
        if vendedores.isEmpty {
            panel.addArrangedSubview(etiqueta("Sin ventas este mes", .footnote, color: .secondaryLabel))
        }
        let maximo = max(vendedores.first?.total ?? 0, 1)
        for vendedor in vendedores {
            panel.addArrangedSubview(etiqueta("\(vendedor.nombre) · \(dinero(vendedor.total))", .footnote))
            let progreso = UIProgressView(progressViewStyle: .default)
            progreso.progress = NSDecimalNumber(decimal: vendedor.total / maximo).floatValue
            progreso.progressTintColor = .azulMaqueta
            progreso.trackTintColor = UIColor(white: 0.92, alpha: 1)
            progreso.heightAnchor.constraint(equalToConstant: 6).isActive = true
            progreso.layer.cornerRadius = 3
            progreso.clipsToBounds = true
            progreso.isAccessibilityElement = false
            panel.addArrangedSubview(progreso)
        }
        return panel
    }

    private func stock(_ productos: [Producto]) -> UIView {
        let panel = tarjeta("Stock bajo (≤ 5)", nil)
        if productos.isEmpty {
            panel.addArrangedSubview(etiqueta("Sin productos con stock bajo", .footnote, color: .secondaryLabel))
        }
        for producto in productos {
            var config = UIButton.Configuration.filled()
            config.title = "Reponer"
            config.baseBackgroundColor = .systemRed
            config.cornerStyle = .capsule
            config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 9, bottom: 4, trailing: 9)
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { atributos in
                var atributos = atributos
                atributos.font = .boldSystemFont(ofSize: 12)
                return atributos
            }
            let boton = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
                self?.reponer(producto)
            })
            boton.setContentCompressionResistancePriority(.required, for: .horizontal)
            let fila = UIStackView(arrangedSubviews: [etiqueta("\(producto.nombre) · \(producto.stock) u.", .headline), boton])
            fila.alignment = .center
            fila.spacing = 8
            panel.addArrangedSubview(fila)
        }
        return panel
    }

    private func reponer(_ producto: Producto) {
        formulario("Reponer stock", campos: [("Stock", String(producto.stock), .numberPad)]) { [weak self] valores in
            guard let self else { return }
            guard let stock = Int64(valores[0]) else { throw ErrorVentas.stockInvalido }
            _ = try repositorio.guardarProducto(producto, nombre: producto.nombre, categoria: producto.categoria,
                                                precio: decimal(producto.precio), stock: stock)
            recargar()
        }
    }

    private func grafico(_ dias: [TotalDiario]) -> UIView {
        let grafico = UIStackView()
        grafico.distribution = .fillEqually
        grafico.spacing = 8
        let maximo = max(1, dias.map(\.total).max() ?? 0)
        for (indice, dia) in dias.enumerated() {
            let marco = UIView()
            marco.heightAnchor.constraint(equalToConstant: 90).isActive = true
            let barra = UIView()
            barra.backgroundColor = indice == dias.count - 1 ? .azulMaqueta : UIColor(red: 0.86, green: 0.90, blue: 0.98, alpha: 1)
            barra.layer.cornerRadius = 4
            barra.isAccessibilityElement = true
            barra.accessibilityLabel = "\(dia.fecha.formatted(date: .abbreviated, time: .omitted)), \(dinero(dia.total))"
            barra.translatesAutoresizingMaskIntoConstraints = false
            marco.addSubview(barra)
            NSLayoutConstraint.activate([
                barra.bottomAnchor.constraint(equalTo: marco.bottomAnchor),
                barra.leadingAnchor.constraint(equalTo: marco.leadingAnchor),
                barra.trailingAnchor.constraint(equalTo: marco.trailingAnchor),
                barra.heightAnchor.constraint(equalToConstant: max(2, 90 * CGFloat(NSDecimalNumber(decimal: dia.total / maximo).doubleValue)))
            ])
            let fecha = UILabel()
            fecha.text = dia.fecha.formatted(.dateTime.weekday(.narrow).locale(Locale(identifier: "es_PE")))
            fecha.textAlignment = .center
            fecha.font = .preferredFont(forTextStyle: .caption1)
            let columna = UIStackView(arrangedSubviews: [marco, fecha])
            columna.axis = .vertical
            columna.spacing = 5
            grafico.addArrangedSubview(columna)
        }
        let tarjeta = tarjeta("Ventas de los últimos 7 días (S/)", nil)
        tarjeta.addArrangedSubview(grafico)
        return tarjeta
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

    @IBOutlet private weak var detalle: UILabel!
    @IBOutlet private weak var salir: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ejecutar {
            let cuenta = try repositorio.exigirSesion()
            detalle.text = "\(cuenta.nombre)\n@\(cuenta.usuario)\n\(cuenta.rol)"
        }
    }

    @IBAction private func salirTocado(_ sender: UIButton) {
        ejecutar {
            try repositorio.salir()
            if let acceso = storyboard?.instantiateInitialViewController() {
                view.window?.rootViewController = acceso
            }
        }
    }

}

extension ControladorVentas {
    var esSupervisor: Bool { (try? repositorio.exigirSesion(.supervisor)) != nil }

    func ejecutar(_ operacion: () throws -> Void) {
        do { try operacion() }
        catch { mensaje("Ventas Tecsup", error.localizedDescription) }
    }

    func mensaje(_ titulo: String, _ texto: String) {
        let alerta = UIAlertController(title: titulo, message: texto, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alerta, animated: true)
    }

    func mostrarSesion(_ cuenta: Usuario) {
        guard let rol = Rol(rawValue: cuenta.rol), let storyboard,
              let pestanas = storyboard.instantiateViewController(withIdentifier: "Pestanas") as? UITabBarController else { return }
        let apariencia = UITabBarAppearance()
        apariencia.configureWithOpaqueBackground()
        apariencia.backgroundColor = UIColor(white: 0.98, alpha: 1)
        pestanas.tabBar.standardAppearance = apariencia
        pestanas.tabBar.scrollEdgeAppearance = apariencia
        pestanas.tabBar.tintColor = .azulMaqueta
        pestanas.viewControllers = PestanaVentas.para(rol).map { pestana in
            let (identificador, titulo) = pestana.escena
            let pantalla = storyboard.instantiateViewController(withIdentifier: identificador)
            let navegacion = UINavigationController(rootViewController: pantalla)
            let icono = UIImage(systemName: "square.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 23))
            navegacion.tabBarItem = UITabBarItem(title: titulo, image: icono, tag: 0)
            navegacion.view.tintColor = .azulMaqueta
            let barra = UINavigationBarAppearance()
            barra.configureWithTransparentBackground()
            navegacion.navigationBar.standardAppearance = barra
            navegacion.navigationBar.scrollEdgeAppearance = barra
            if identificador == "A9" { navegacion.setNavigationBarHidden(true, animated: false) }
            return navegacion
        }
        view.window?.rootViewController = pestanas
    }

    func formulario(_ titulo: String, campos: [(String, String?, UIKeyboardType)],
                    guardar: @escaping ([String]) throws -> Void) {
        let alerta = UIAlertController(title: titulo, message: nil, preferredStyle: .alert)
        for (etiqueta, valor, teclado) in campos {
            alerta.addTextField { campo in
                campo.placeholder = etiqueta
                campo.accessibilityLabel = etiqueta
                campo.text = valor
                campo.keyboardType = teclado
            }
        }
        alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alerta.addAction(UIAlertAction(title: "Guardar", style: .default) { [weak self, weak alerta] _ in
            guard let self, let camposAlerta = alerta?.textFields else { return }
            let datos = camposAlerta.map { $0.text ?? "" }
            do { try guardar(datos) }
            catch {
                let aviso = UIAlertController(title: "Revisa los datos", message: error.localizedDescription, preferredStyle: .alert)
                aviso.addAction(UIAlertAction(title: "Volver", style: .default) { [weak self] _ in
                    let valores = zip(campos, datos).map { ($0.0.0, Optional($0.1), $0.0.2) }
                    self?.formulario(titulo, campos: valores, guardar: guardar)
                })
                present(aviso, animated: true)
            }
        })
        present(alerta, animated: true)
    }

    func confirmarBorrado(_ nombre: String, borrar: @escaping () throws -> Void) {
        let alerta = UIAlertController(title: "Borrar registro", message: nombre, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alerta.addAction(UIAlertAction(title: "Borrar", style: .destructive) { [weak self] _ in self?.ejecutar(borrar) })
        present(alerta, animated: true)
    }
}

private extension PestanaVentas {
    var escena: (String, String) {
        switch self {
        case .resumen: return ("A9", "Resumen")
        case .ventasEquipo: return ("A7", "Ventas")
        case .productos: return ("A3", "Productos")
        case .clientes: return ("A4", "Clientes")
        case .nuevaVenta: return ("A5", "Venta")
        case .misVentas: return ("A6", "Mis ventas")
        case .cuenta: return ("Cuenta", "Cuenta")
        }
    }
}

struct FilaVentas {
    let titulo: String
    let subtitulo: String
    let valor: String
    let icono: String
    let color: UIColor
    var anulada = false
    var distintivo: String?
    var colorDistintivo: UIColor?
    var comprado = false
    var tocar: (() -> Void)?
    var accion: String?
    var deslizar: (() -> Void)?
}

class ControladorListaVentas: ControladorVentas, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var lista: UITableView!
    var notaLista: String? { nil }
    var filas: [FilaVentas] = [] {
        didSet {
            let vacio = UILabel()
            vacio.text = "Sin resultados"
            vacio.textAlignment = .center
            vacio.textColor = .secondaryLabel
            lista.backgroundView = filas.isEmpty ? vacio : nil
            lista.reloadData()
            if filas.isEmpty { lista.tableFooterView = UIView() }
            view.setNeedsLayout()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        lista.dataSource = self
        lista.delegate = self
        lista.register(UITableViewCell.self, forCellReuseIdentifier: "Fila")
        lista.backgroundColor = .clear
        lista.layer.cornerRadius = 14
        lista.keyboardDismissMode = .onDrag
        lista.rowHeight = UITableView.automaticDimension
        lista.estimatedRowHeight = 57
        lista.separatorColor = UIColor(white: 0.92, alpha: 1)
        lista.tableFooterView = UIView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let notaLista, !filas.isEmpty else { return }
        let ancho = lista.bounds.width
        guard ancho > 16, lista.tableFooterView?.bounds.width != ancho else { return }
        let nota = etiqueta(notaLista, .footnote, color: .secondaryLabel)
        let alto = nota.sizeThatFits(CGSize(width: ancho - 16, height: .greatestFiniteMagnitude)).height
        let pie = UIView(frame: CGRect(x: 0, y: 0, width: ancho, height: alto + 18))
        nota.frame = CGRect(x: 8, y: 10, width: ancho - 16, height: alto)
        pie.addSubview(nota)
        lista.tableFooterView = pie
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { filas.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fila = filas[indexPath.row]
        let celda = tableView.dequeueReusableCell(withIdentifier: "Fila", for: indexPath)
        let avatar = UILabel()
        avatar.textAlignment = .center
        avatar.text = fila.icono
        avatar.textColor = .white
        avatar.backgroundColor = fila.color
        avatar.layer.cornerRadius = 10
        avatar.clipsToBounds = true
        avatar.font = .preferredFont(forTextStyle: .caption1)
        avatar.widthAnchor.constraint(equalToConstant: 36).isActive = true
        avatar.heightAnchor.constraint(equalToConstant: 36).isActive = true

        let titulo = etiqueta(fila.titulo, .headline, color: fila.anulada ? .secondaryLabel : .label)
        titulo.numberOfLines = 1
        let subtitulo = etiqueta(fila.subtitulo, .caption1, color: .secondaryLabel)
        subtitulo.numberOfLines = 1
        let texto = UIStackView(arrangedSubviews: [titulo, subtitulo])
        texto.axis = .vertical
        texto.spacing = 3
        let valor = etiqueta(fila.valor, .subheadline, color: fila.anulada ? .secondaryLabel : .label)
        valor.textAlignment = .right
        valor.font = .boldSystemFont(ofSize: 15)
        valor.setContentHuggingPriority(.required, for: .horizontal)
        valor.setContentCompressionResistancePriority(.required, for: .horizontal)
        if fila.anulada {
            valor.attributedText = NSAttributedString(string: fila.valor, attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        }
        let importe = UIStackView(arrangedSubviews: [valor])
        importe.axis = .vertical
        importe.alignment = .trailing
        if fila.comprado {
            importe.addArrangedSubview(etiqueta("comprado", .caption2, color: .secondaryLabel))
        }
        let filaView = UIStackView(arrangedSubviews: [avatar, texto, importe])
        if let distintivo = fila.distintivo, let color = fila.colorDistintivo {
            let marca = insignia(distintivo, color: color)
            if fila.anulada {
                texto.alignment = .leading
                texto.addArrangedSubview(marca)
            } else {
                filaView.addArrangedSubview(marca)
            }
        }
        filaView.spacing = 8
        filaView.alignment = .center
        filaView.translatesAutoresizingMaskIntoConstraints = false
        celda.contentView.subviews.forEach { $0.removeFromSuperview() }
        celda.contentView.addSubview(filaView)
        let margen = celda.contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            filaView.leadingAnchor.constraint(equalTo: margen.leadingAnchor),
            filaView.trailingAnchor.constraint(equalTo: margen.trailingAnchor),
            filaView.topAnchor.constraint(equalTo: margen.topAnchor),
            filaView.bottomAnchor.constraint(equalTo: margen.bottomAnchor)
        ])
        celda.selectionStyle = fila.tocar == nil ? .none : .default
        celda.isAccessibilityElement = true
        celda.accessibilityLabel = [fila.titulo, fila.subtitulo, fila.valor, fila.distintivo].compactMap { $0 }.joined(separator: ", ")
        celda.accessibilityCustomActions = []
        if let nombre = fila.accion, let accion = fila.deslizar {
            celda.accessibilityCustomActions = [UIAccessibilityCustomAction(name: nombre) { _ in accion(); return true }]
        }
        return celda
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        filas[indexPath.row].tocar?()
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let fila = filas[indexPath.row]
        guard let titulo = fila.accion, let accion = fila.deslizar else { return nil }
        let configuracion = UISwipeActionsConfiguration(actions: [
            UIContextualAction(style: .destructive, title: titulo) { _, _, terminar in
                terminar(true)
                accion()
            }
        ])
        configuracion.performsFirstActionWithFullSwipe = false
        return configuracion
    }
}

private final class SelectorVentasViewController: ControladorListaVentas, UISearchResultsUpdating {
    var buscar: ((String) throws -> [(String, () -> Void)])?
    private let tabla = UITableView()

    // Este selector reutiliza la tabla de las listas, con búsqueda en la barra de navegación.
    override func loadView() {
        view = tabla
        lista = tabla
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let buscador = UISearchController(searchResultsController: nil)
        buscador.obscuresBackgroundDuringPresentation = false
        buscador.searchResultsUpdater = self
        buscador.searchBar.placeholder = "Buscar"
        navigationItem.searchController = buscador
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        updateSearchResults(for: buscador)
    }

    func updateSearchResults(for searchController: UISearchController) {
        ejecutar {
            filas = try (buscar?(searchController.searchBar.text ?? "") ?? []).map { nombre, elegir in
                var fila = FilaVentas(titulo: nombre, subtitulo: "", valor: "", icono: iniciales(nombre), color: .systemBlue)
                fila.tocar = { [weak self, weak searchController] in
                    searchController?.isActive = false
                    elegir()
                    self?.navigationController?.popViewController(animated: true)
                }
                return fila
            }
        }
    }
}

private func etiqueta(_ texto: String, _ estilo: UIFont.TextStyle, color: UIColor = .label) -> UILabel {
    let etiqueta = UILabel()
    etiqueta.text = texto
    etiqueta.font = .preferredFont(forTextStyle: estilo)
    etiqueta.adjustsFontForContentSizeCategory = true
    etiqueta.textColor = color
    etiqueta.numberOfLines = 0
    return etiqueta
}

private func iniciales(_ nombre: String) -> String {
    nombre.split(whereSeparator: \.isWhitespace).prefix(2).compactMap(\.first).map(String.init).joined().uppercased()
}

private func dinero(_ valor: Decimal) -> String {
    valor.formatted(.currency(code: "PEN").locale(Locale(identifier: "es_PE")))
}

private func dinero(_ valor: Double) -> String {
    valor.formatted(.currency(code: "PEN").locale(Locale(identifier: "es_PE")))
}

private func tarjeta(_ titulo: String, _ valor: String?, _ detalle: String? = nil) -> UIStackView {
    let tarjeta = UIStackView()
    tarjeta.axis = .vertical
    tarjeta.spacing = 5
    tarjeta.backgroundColor = .white
    tarjeta.layer.cornerRadius = 14
    tarjeta.isLayoutMarginsRelativeArrangement = true
    tarjeta.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    tarjeta.addArrangedSubview(etiqueta(titulo, .subheadline, color: .secondaryLabel))
    if let valor {
        let principal = etiqueta(valor, .title2)
        principal.font = .boldSystemFont(ofSize: 24)
        tarjeta.addArrangedSubview(principal)
    }
    if let detalle { tarjeta.addArrangedSubview(etiqueta(detalle, .caption1, color: .secondaryLabel)) }
    return tarjeta
}

private func chips(_ scroll: UIScrollView, titulos: [String], seleccion: Int, elegir: @escaping (Int) -> Void) {
    let offset = scroll.contentOffset
    scroll.subviews.forEach { $0.removeFromSuperview() }
    let stack = UIStackView()
    stack.spacing = 8
    stack.alignment = .center
    stack.translatesAutoresizingMaskIntoConstraints = false
    scroll.addSubview(stack)
    NSLayoutConstraint.activate([
        stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
        stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
        stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
        stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
        stack.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor)
    ])
    for (indice, titulo) in titulos.enumerated() {
        var configuracion = indice == seleccion ? UIButton.Configuration.filled() : .tinted()
        configuracion.cornerStyle = .capsule
        configuracion.title = titulo
        configuracion.baseForegroundColor = indice == seleccion ? .white : .label
        configuracion.baseBackgroundColor = indice == seleccion ? .azulMaqueta : .white
        configuracion.background.strokeColor = UIColor(white: 0.88, alpha: 1)
        configuracion.background.strokeWidth = indice == seleccion ? 0 : 1
        configuracion.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 12, bottom: 5, trailing: 12)
        configuracion.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { atributos in
            var atributos = atributos
            atributos.font = .systemFont(ofSize: 13)
            return atributos
        }
        let boton = UIButton(configuration: configuracion, primaryAction: UIAction { _ in elegir(indice) })
        boton.accessibilityIdentifier = "Filtro " + titulo
        if indice == seleccion { boton.accessibilityTraits.insert(.selected) }
        stack.addArrangedSubview(boton)
    }
    scroll.layoutIfNeeded()
    scroll.contentOffset = CGPoint(x: min(offset.x, max(0, scroll.contentSize.width - scroll.bounds.width)), y: 0)
}

private func detalleVenta(_ venta: Venta) -> String {
    var lineas = [
        "\(venta.producto.nombre) × \(venta.cantidad)",
        "Precio unitario: \(dinero(venta.precioUnitario))",
        "Descuento: \(dinero(venta.descuento))",
        "IGV: \(dinero(venta.igv))",
        "Total: \(dinero(venta.total))"
    ]
    if let motivo = venta.motivoAnulacion { lineas.append("Anulada · \(motivo)") }
    return lineas.joined(separator: "\n")
}

private func filaVenta(_ venta: Venta, incluirVendedor: Bool = false) -> FilaVentas {
    let fecha = venta.fecha.formatted(.dateTime.day(.twoDigits).month(.twoDigits).locale(Locale(identifier: "es_PE")))
    let identificador = incluirVendedor ? venta.vendedor.nombre : fecha
    let icono = incluirVendedor ? iniciales(venta.cliente.nombre) : venta.anulada ? "×" : "✓"
    let color: UIColor = incluirVendedor ? colorCategoria(venta.cliente.nombre) : venta.anulada ? .systemRed : .systemGreen
    return FilaVentas(titulo: venta.cliente.nombre,
                      subtitulo: "\(identificador) · \(venta.producto.nombre) × \(venta.cantidad)",
                      valor: dinero(venta.total), icono: icono, color: color, anulada: venta.anulada,
                      distintivo: venta.anulada ? "Anulada" : nil, colorDistintivo: .systemRed)
}

private extension UISegmentedControl {
    var periodoVenta: PeriodoVentas {
        switch selectedSegmentIndex {
        case 1: return .hoy
        case 2: return .mes
        default: return .todas
        }
    }
}

private extension UIStackView {
    func vaciar() { arrangedSubviews.forEach { $0.removeFromSuperview() } }
}

private extension Producto {
    var colorStock: UIColor {
        switch NivelStock(unidades: stock) {
        case .bajo: return .systemRed
        case .medio: return .systemOrange
        case .alto: return .systemGreen
        }
    }
}

final class TarjetaMaqueta: UIStackView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 13
        layer.masksToBounds = true
    }
}

final class CampoMaqueta: UIStackView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 13
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 0.87, alpha: 1).cgColor
        layer.masksToBounds = true
        let vistaTitulo = arrangedSubviews.first
        let titulo = vistaTitulo as? UILabel ?? (vistaTitulo as? UIStackView)?.arrangedSubviews.first as? UILabel
        let campo = arrangedSubviews.last as? UITextField
        campo?.accessibilityLabel = titulo?.text
        campo?.textColor = .label
    }
}

final class BusquedaMaqueta: UITextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor(white: 0.89, alpha: 1)
        layer.cornerRadius = 10
        font = .systemFont(ofSize: 15)
        textColor = .label
        clearButtonMode = .whileEditing
        if let placeholder { accessibilityLabel = placeholder }
        let icono = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icono.tintColor = .secondaryLabel
        icono.contentMode = .center
        icono.frame = CGRect(x: 0, y: 0, width: 31, height: 30)
        leftView = icono
        leftViewMode = .always
    }

}

private extension UIColor {
    static let azulMaqueta = UIColor(red: 0.04, green: 0.43, blue: 0.96, alpha: 1)
}

private extension UIButton {
    func aplicarBotonPrincipal() {
        configuration?.baseBackgroundColor = .azulMaqueta
        configuration?.cornerStyle = .large
    }
}

private func colorCategoria(_ texto: String) -> UIColor {
    let colores: [UIColor] = [.systemIndigo, .systemPurple, .systemTeal, .systemPink]
    let indice = texto.utf8.reduce(0) { ($0 + Int($1)) % colores.count }
    return colores[indice]
}

private func insignia(_ texto: String, color: UIColor) -> UIStackView {
    let titulo = etiqueta(texto, .caption2, color: .white)
    titulo.font = .boldSystemFont(ofSize: 11)
    titulo.numberOfLines = 1
    titulo.setContentCompressionResistancePriority(.required, for: .horizontal)
    let fondo = UIStackView(arrangedSubviews: [titulo])
    fondo.backgroundColor = color
    fondo.layer.cornerRadius = 9
    fondo.isLayoutMarginsRelativeArrangement = true
    fondo.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 3, leading: 8, bottom: 3, trailing: 8)
    return fondo
}
