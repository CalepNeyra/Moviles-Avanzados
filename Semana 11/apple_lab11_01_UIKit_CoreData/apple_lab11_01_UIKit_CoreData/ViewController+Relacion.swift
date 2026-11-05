import UIKit
import CoreData

extension ViewController {
    func buscarContactos(texto: String) -> [Contacto] {
        let request: NSFetchRequest<Contacto> = Contacto.fetchRequest()
        request.predicate = NSPredicate(format: "nombre CONTAINS[cd] %@", texto)
        request.sortDescriptors = [NSSortDescriptor(key: "nombre", ascending: true)]
        return (try? conexion().fetch(request)) ?? []
    }

    // Demostración del laboratorio. Llamar una sola vez con contactos cargados.
    func probarRelacion() {
        let contexto = conexion()
        let grupo = NSEntityDescription.insertNewObject(forEntityName: "Grupo", into: contexto) as! Grupo
        grupo.nombre = "Amigos"
        contactos.first?.grupo = grupo

        do {
            try contexto.save()
            print("El grupo \(grupo.nombre ?? "") tiene \(grupo.contactos?.count ?? 0) contacto(s)")
        } catch {
            contexto.rollback()
            print("Error al guardar la relación: \(error)")
        }
    }

    func contactosDelGrupo(_ nombreGrupo: String) -> [Contacto] {
        let request: NSFetchRequest<Contacto> = Contacto.fetchRequest()
        request.predicate = NSPredicate(format: "grupo.nombre == %@", nombreGrupo)
        return (try? conexion().fetch(request)) ?? []
    }
}
