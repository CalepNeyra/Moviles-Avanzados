//
//  ViewController.swift
//  apple_lab11_01_UIKit_CoreData
//
//  Created by Tecsup on 5/11/26.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    @IBOutlet weak var TablaContacto: UITableView!
    var contactos = [Contacto]()
    private let buscador = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        TablaContacto.dataSource = self
        TablaContacto.delegate = self
        buscador.searchResultsUpdater = self
        buscador.obscuresBackgroundDuringPresentation = false
        buscador.searchBar.placeholder = "Buscar por nombre"
        navigationItem.searchController = buscador
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        mostrarRutaBaseDeDatos()
        cargarInfoCoreData()
    }

    // MARK: - Conexión con Core Data

    func conexion() -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }

    func mostrarRutaBaseDeDatos() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let ruta = delegate.persistentContainer.persistentStoreDescriptions.first?.url?.path ?? "sin ruta"
        print("Base de datos SQLite en: \(ruta)")
    }

    // MARK: - READ

    func cargarInfoCoreData() {
        let texto = buscador.searchBar.text ?? ""
        if buscador.isActive && !texto.isEmpty {
            contactos = buscarContactos(texto: texto)
            return
        }

        let contexto = conexion()
        let fetchRequest: NSFetchRequest<Contacto> = Contacto.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "nombre", ascending: true)]

        do {
            contactos = try contexto.fetch(fetchRequest)
        } catch {
            print("Error al cargar la BD: \(error)")
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        cargarInfoCoreData()
        TablaContacto.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let contacto = contactos[indexPath.row]
        celda.textLabel?.text = contacto.nombre
        celda.detailTextLabel?.text = "\(contacto.telefono ?? "") | \(contacto.direccion ?? "")"
        return celda
    }

    // MARK: - CREATE

    @IBAction func agregarContacto(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Agregar Contacto", message: "Nuevo Contacto", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Nombre" }
        alert.addTextField { $0.placeholder = "Telefono" }
        alert.addTextField { $0.placeholder = "Direccion" }

        let actionAceptar = UIAlertAction(title: "Aceptar", style: .default) { [weak self, weak alert] _ in
            guard let self, let nombre = alert?.textFields?[0].text, !nombre.isEmpty else { return }
            let contexto = self.conexion()
            let entidad = NSEntityDescription.insertNewObject(forEntityName: "Contacto", into: contexto) as! Contacto
            entidad.nombre = nombre
            entidad.telefono = alert?.textFields?[1].text ?? ""
            entidad.direccion = alert?.textFields?[2].text ?? ""

            do {
                try contexto.save()
                self.cargarInfoCoreData()
                self.TablaContacto.reloadData()
            } catch {
                contexto.rollback()
                print("Error al guardar el dato: \(error)")
            }
        }
        alert.addAction(actionAceptar)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - UPDATE

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let contacto = contactos[indexPath.row]
        let alert = UIAlertController(title: "Editar Contacto", message: "Modifica los datos", preferredStyle: .alert)
        alert.addTextField { $0.text = contacto.nombre }
        alert.addTextField { $0.text = contacto.telefono }
        alert.addTextField { $0.text = contacto.direccion }

        let actionGuardar = UIAlertAction(title: "Guardar", style: .default) { [weak self, weak alert] _ in
            guard let self, let nombre = alert?.textFields?[0].text, !nombre.isEmpty else { return }
            let contexto = self.conexion()
            contacto.nombre = nombre
            contacto.telefono = alert?.textFields?[1].text
            contacto.direccion = alert?.textFields?[2].text

            do {
                try contexto.save()
                self.cargarInfoCoreData()
                self.TablaContacto.reloadData()
            } catch {
                contexto.rollback()
                print("Error al actualizar: \(error)")
            }
        }
        alert.addAction(actionGuardar)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - DELETE

    func eliminarContacto(at indexPath: IndexPath) {
        let contexto = conexion()
        contexto.delete(contactos[indexPath.row])

        do {
            try contexto.save()
            contactos.remove(at: indexPath.row)
            TablaContacto.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            contexto.rollback()
            print("Error al eliminar: \(error)")
        }
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            eliminarContacto(at: indexPath)
        }
    }
}

