import Foundation
import Observation
import SwiftData

@Observable
class EmployeeViewModel {
    private func validName(_ name: String) -> String? {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleanName.isEmpty ? nil : cleanName
    }

    func addEmployee(from draft: Employee, context: ModelContext) -> OperationResult {
        guard let name = validName(draft.name), draft.salary >= 0,
              draft.absences >= 0 else {
            return .invalidData
        }

        context.insert(Employee(name: name, salary: draft.salary,
                                absences: draft.absences))
        do {
            try context.save()
            return .success
        } catch {
            context.rollback()
            return .saveError
        }
    }

    func updateEmployee(_ employee: Employee, from draft: Employee,
                        context: ModelContext) -> OperationResult {
        guard let name = validName(draft.name), draft.salary >= 0,
              draft.absences >= 0 else {
            return .invalidData
        }

        employee.name = name
        employee.salary = draft.salary
        employee.absences = draft.absences
        do {
            try context.save()
            return .success
        } catch {
            context.rollback()
            return .saveError
        }
    }

    func deleteEmployees(at offsets: IndexSet, from employees: [Employee],
                         context: ModelContext) -> OperationResult {
        for index in offsets {
            context.delete(employees[index])
        }
        do {
            try context.save()
            return .success
        } catch {
            context.rollback()
            return .saveError
        }
    }
}
