//
//  ViewController.swift
//  CulturasPeruanas
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    // Lista de culturas peruanas a mostrar en la Pantalla 1
    var listaCulturas: [Cultura] = [
        Cultura(nombre: "Chavín", region: "Áncash", descripcion: "Famosa por el Lanzón Monolítico y las Cabezas Clavas.", imagen: "chavin"),
        Cultura(nombre: "Paracas", region: "Ica", descripcion: "Famosa por sus mantos textiles y trepanaciones craneanas.", imagen: "paracas"),
        Cultura(nombre: "Moche", region: "La Libertad", descripcion: "Conocida por sus huacos retratos y el Señor de Sipán.", imagen: "moche"),
        Cultura(nombre: "Nazca", region: "Ica", descripcion: "Famosa por los geoglifos de las Líneas de Nazca.", imagen: "nazca"),
        Cultura(nombre: "Inca", region: "Cusco", descripcion: "Imperio andino, constructores de Machu Picchu.", imagen: "inca")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Culturas Peruanas"
        
        // Asignación segura de delegados
        if let tv = tableView {
            tv.delegate = self
            tv.dataSource = self
        }
    }

    // MARK: - UITableView DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaCulturas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "culturaCell", for: indexPath) as? CulturaTableViewCell else {
            return UITableViewCell()
        }
        
        let cultura = listaCulturas[indexPath.row]
        cell.nombreCulturaLabel?.text = cultura.nombre
        cell.imagenCultura?.image = UIImage(named: cultura.imagen)
        
        return cell
    }
}
