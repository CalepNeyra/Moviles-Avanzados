import SwiftUI
import SwiftData

struct EditarAlumnoView: View {
    @Bindable var alumno: Alumno
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Datos del Alumno")) {
                    TextField("Apellido", text: $alumno.apellido)
                    TextField("Nombre", text: $alumno.nombre)
                    TextField("DNI", text: $alumno.dni)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Editar Alumno")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") {
                        do {
                            try modelContext.save()
                            dismiss()
                        } catch {
                            print("Error al guardar alumno: \(error)")
                        }
                    }
                }
            }
        }
    }
}
