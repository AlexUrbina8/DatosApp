import SwiftUI
import SwiftData

struct ProductListView: View {
    @Query(sort: \Product.name) private var products: [Product]
    @State private var viewModel = ProductViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var showingAdd = false
    @State private var showingError = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredProducts(from: products)) { product in
                    NavigationLink {
                        ProductDetailView(product: product, viewModel: viewModel)
                    } label: {
                        Text(product.name)
                    }
                }
                .onDelete { offsets in
                    let visibleProducts = viewModel.filteredProducts(from: products)
                    let result = viewModel.deleteProducts(at: offsets,
                                                          from: visibleProducts,
                                                          context: modelContext)
                    showingError = result == .saveError
                }
            }
            .navigationTitle("Productos")
            .searchable(text: $viewModel.searchText, prompt: "Buscar producto")
            .toolbar {
                Button("Agregar", systemImage: "plus") {
                    showingAdd = true
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddProductView(viewModel: viewModel)
            }
            .alert("Error", isPresented: $showingError) {
                Button("Aceptar") { }
            } message: {
                Text("No se pudo eliminar el producto.")
            }
        }
    }
}

struct ProductFields: View {
    @Bindable var product: Product

    var body: some View {
        TextField("Nombre", text: $product.name)
        TextField("Precio", value: $product.price, format: .number)
            .keyboardType(.decimalPad)
    }
}

struct AddProductView: View {
    let viewModel: ProductViewModel
    @State private var draft = Product(name: "", price: 0)
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Producto") {
                    ProductFields(product: draft)
                }
            }
            .navigationTitle("Agregar producto")
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
        let result = viewModel.addProduct(from: draft, context: modelContext)
        switch result {
        case .success:
            dismiss()
        case .invalidData:
            errorMessage = "Escribe un nombre y un precio mayor o igual a cero."
            showingError = true
        case .saveError:
            errorMessage = "No se pudo guardar el producto."
            showingError = true
        }
    }
}

struct ProductDetailView: View {
    let product: Product
    let viewModel: ProductViewModel
    @State private var draft = Product(name: "", price: 0)
    @State private var isEditing = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Form {
            Section("Producto") {
                if isEditing {
                    ProductFields(product: draft)
                } else {
                    LabeledContent("Nombre", value: product.name)
                    LabeledContent("Precio") {
                        Text(product.price, format: .number)
                    }
                }
            }
        }
        .navigationTitle("Producto")
        .toolbar {
            if isEditing {
                Button("Cancelar") { isEditing = false }
                Button("Guardar") { save() }
            } else {
                Button("Editar") {
                    draft.name = product.name
                    draft.price = product.price
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
        let result = viewModel.updateProduct(product, from: draft,
                                             context: modelContext)
        switch result {
        case .success:
            isEditing = false
        case .invalidData:
            errorMessage = "Escribe un nombre y un precio mayor o igual a cero."
            showingError = true
        case .saveError:
            errorMessage = "No se pudo guardar el producto."
            showingError = true
        }
    }
}
