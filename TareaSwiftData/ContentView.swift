import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ProductListView()
                .tabItem {
                    Label("Productos", systemImage: "shippingbox")
                }

            EmployeeListView()
                .tabItem {
                    Label("Empleados", systemImage: "person.2")
                }
        }
    }
}
