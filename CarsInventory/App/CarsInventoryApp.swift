//
//  CarsInventoryApp.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-04.
//

import SwiftUI
import SwiftData

@main
struct CarsInventoryApp: App {
    
    @AppStorage("didLoadData") private var didLoadData: Bool = false
    
    var body: some Scene {
        #if DEBUG
            #if targetEnvironment(simulator)
            let modelContainer = CarsInventoryAppPreviewData.container
            print("startup at line: \(#line)")
            #else
            let modelContainer = ModelContainer.shared
            print("startup at line: \(#line), didLoadData: ", didLoadData)
            if didLoadData == false {
                DefaultDataProvider.populateWithDefaultData(modelContainer: modelContainer)
                didLoadData = true
            }
            #endif
        #else
        let modelContainer = ModelContainer.shared
        print("startup at line: \(#line), didLoadData: ", didLoadData)
        if didLoadData == false {
            DefaultDataProvider.populateWithDefaultData(modelContainer: modelContainer)
            didLoadData = true
        }
        #endif
        
        return WindowGroup {
            MainTabView()
        }
        .modelContainer(modelContainer)
    }
}

// MARK: - ModelContainer

private extension ModelContainer {
    @MainActor
    static let shared: ModelContainer = {
        do {
            let schema = Schema([Series.self, InventoryCar.self, Franchise.self])
            
//            let modelConfiguration = ModelConfiguration(
//                schema: schema,
//                isStoredInMemoryOnly: false,
//                cloudKitDatabase: .private("iCloud.com.bakehouse.CarsInventory")
//            )
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            return modelContainer
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
