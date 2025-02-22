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
    
    var body: some Scene {
        #if DEBUG
            #if !targetEnvironment(simulator)
//            let modelContainer = ModelContainer.shared
            let modelContainer = CarsInventoryAppPreviewData.container
        print("\(#line)")
            #elseif os(watchOS)
            let modelContainer = CarsInventoryAppPreviewData.container
        print("\(#line)")
            #else
            let modelContainer = CarsInventoryAppPreviewData.container
        print("\(#line)")
            #endif
        #else
        let modelContainer = ModelContainer.shared
        print("\(#line)")
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
            let schema = Schema([
                Series.self,
            ])
            
            // TODO: - specify group id???
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            modelContainer.insertSeries()
            return modelContainer
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
