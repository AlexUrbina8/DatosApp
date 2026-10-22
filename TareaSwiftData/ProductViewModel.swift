import Foundation
import Observation
import SwiftData

@Observable
class ProductViewModel {
    var searchText = ""

    func filteredProducts(from products: [Product]) -> [Product] {
        let search = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !search.isEmpty else { return products }
        return products.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    private func validName(_ name: String) -> String? {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleanName.isEmpty ? nil : cleanName
    }

    func addProduct(from draft: Product, context: ModelContext) -> OperationResult {
        guard let name = validName(draft.name), draft.price >= 0 else {
            return .invalidData
        }

        context.insert(Product(name: name, price: draft.price))
        do {
            try context.save()
            return .success
        } catch {
            context.rollback()
            return .saveError
        }
    }

    func updateProduct(_ product: Product, from draft: Product,
                       context: ModelContext) -> OperationResult {
        guard let name = validName(draft.name), draft.price >= 0 else {
            return .invalidData
        }

        product.name = name
        product.price = draft.price
        do {
            try context.save()
            return .success
        } catch {
            context.rollback()
            return .saveError
        }
    }

    func deleteProducts(at offsets: IndexSet, from products: [Product],
                        context: ModelContext) -> OperationResult {
        for index in offsets {
            context.delete(products[index])
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
