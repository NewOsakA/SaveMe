import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }

            TransactionListView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet")
                }

            BudgetView()
                .tabItem {
                    Label("Budget", systemImage: "chart.pie.fill")
                }
            
            BillingView()
                .tabItem {
                    Label("Billing", systemImage: "creditcard.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
    
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AuthManager()) 
    }
}
