//
//  MainTabView.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-05.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    
    var body: some View {
        TabView {
            Tab("Inventory", systemImage: "car") {
                NavigationStack {
                    InventoryCarsView()
                        .toolbarBackground(.visible, for: .tabBar)
                }
            }

            Tab("Scan", systemImage: "camera.viewfinder") {
                ScanningView()
                    .toolbarBackground(.visible, for: .tabBar)
//                    .ignoresSafeArea(.all, edges: .top)
            }
            
            Tab("Settings", systemImage: "gear") {
                SettingsView()
                    .toolbarBackground(.visible, for: .tabBar)
                    .ignoresSafeArea(.all, edges: .top)
            }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(CarsInventoryAppContainerSampleData.container)
}
