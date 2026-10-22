import SwiftUI
import SwiftData

struct EmployeeListView: View {
    @Query(sort: \Employee.name) private var employees: [Employee]
    @State private var viewModel = EmployeeViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var showingAdd = false
    @State private var showingError = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(employees) { employee in
                    NavigationLink {
                        EmployeeDetailView(employee: employee, viewModel: viewModel)
                    } label: {
                        Text(employee.name)
                    }
                }
                .onDelete { offsets in
                    let result = viewModel.deleteEmployees(at: offsets,
                                                            from: employees,
                                                            context: modelContext)
                    showingError = result == .saveError
                }
            }
            .navigationTitle("Empleados")
            .toolbar {
                Button("Agregar", systemImage: "plus") {
                    showingAdd = true
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEmployeeView(viewModel: viewModel)
            }
            .alert("Error", isPresented: $showingError) {
                Button("Aceptar") { }
            } message: {
                Text("No se pudo eliminar el empleado.")
            }
        }
    }
}

struct EmployeeFields: View {
    @Bindable var employee: Employee

    var body: some View {
        TextField("Nombre", text: $employee.name)
        TextField("Sueldo", value: $employee.salary, format: .number)
            .keyboardType(.decimalPad)
        TextField("Faltas", value: $employee.absences, format: .number)
            .keyboardType(.numberPad)
    }
}

struct AddEmployeeView: View {
    let viewModel: EmployeeViewModel
    @State private var draft = Employee(name: "", salary: 0, absences: 0)
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Empleado") {
                    EmployeeFields(employee: draft)
                }
            }
            .navigationTitle("Agregar empleado")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("Aceptar") { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func save() {
        let result = viewModel.addEmployee(from: draft, context: modelContext)
        switch result {
        case .success:
            dismiss()
        case .invalidData:
            errorMessage = "Escribe un nombre, un sueldo y faltas mayores o iguales a cero."
            showingError = true
        case .saveError:
            errorMessage = "No se pudo guardar el empleado."
            showingError = true
        }
    }
}

struct EmployeeDetailView: View {
    let employee: Employee
    let viewModel: EmployeeViewModel
    @State private var draft = Employee(name: "", salary: 0, absences: 0)
    @State private var isEditing = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Form {
            Section("Empleado") {
                if isEditing {
                    EmployeeFields(employee: draft)
                } else {
                    LabeledContent("Nombre", value: employee.name)
                    LabeledContent("Sueldo") {
                        Text(employee.salary, format: .number)
                    }
                    LabeledContent("Faltas", value: "\(employee.absences)")
                }
            }
        }
        .navigationTitle("Empleado")
        .toolbar {
            if isEditing {
                Button("Cancelar") { isEditing = false }
                Button("Guardar") { save() }
            } else {
                Button("Editar") {
                    draft.name = employee.name
                    draft.salary = employee.salary
                    draft.absences = employee.absences
                    isEditing = true
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("Aceptar") { }
        } message: {
            Text(errorMessage)
        }
    }

    private func save() {
        let result = viewModel.updateEmployee(employee, from: draft,
                                              context: modelContext)
        switch result {
        case .success:
            isEditing = false
        case .invalidData:
            errorMessage = "Escribe un nombre, un sueldo y faltas mayores o iguales a cero."
            showingError = true
        case .saveError:
            errorMessage = "No se pudo guardar el empleado."
            showingError = true
        }
    }
}
