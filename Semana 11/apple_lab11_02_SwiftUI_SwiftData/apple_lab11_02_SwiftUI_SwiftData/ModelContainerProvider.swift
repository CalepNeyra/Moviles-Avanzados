import Foundation
import SwiftData

@MainActor
class ModelContainerProvider {
    static let shared = ModelContainerProvider()

    let container: ModelContainer

    private init() {
        let schema = Schema([Alumno.self, Curso.self])
        do {
            let config = ModelConfiguration(
                "AlumnosData",
                schema: schema,
                url: FileManager.default
                    .urls(for: .applicationSupportDirectory, in: .userDomainMask)
                    .first!
                    .appendingPathComponent("AlumnosData.sqlite")
            )
            print("Base de datos SQLite en: \(config.url.path)")
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Error al inicializar ModelContainer: \(error)")
        }
    }
}
