import Foundation
import SwiftData

@Model
final class Product {
    var name: String
    var price: Decimal

    init(name: String, price: Decimal) {
        self.name = name
        self.price = price
    }
}
