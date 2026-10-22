import Foundation
import SwiftData

@Model
final class Employee {
    var name: String
    var salary: Decimal
    var absences: Int

    init(name: String, salary: Decimal, absences: Int) {
        self.name = name
        self.salary = salary
        self.absences = absences
    }
}
