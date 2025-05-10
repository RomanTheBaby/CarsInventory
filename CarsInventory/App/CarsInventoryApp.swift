//
//  CarsInventoryApp.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-04.
//

import SwiftUI
import SwiftData
import TipKit
import OSLog

@main
struct CarsInventoryApp: App {
    
    // MARK: - Properties
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? String(describing: CarsInventoryApp.self),
        category: String(describing: CarsInventoryApp.self)
    )
    
    @AppStorage("didLoadData") private var didLoadData: Bool = false
    
    // MARK: - Body
    
    var body: some Scene {
        let modelContainer = createModelContainer()
        configureTips()
        return WindowGroup {
            MainTabView()
        }
        .modelContainer(modelContainer)
    }
    
    // MARK: - Private Methods

    private func createModelContainer() -> ModelContainer {
        #if DEBUG
            #if targetEnvironment(simulator)
                let modelContainer = CarsInventoryAppPreviewData.container
                logger.info("Startup in debug configuration. Target environment - simulator")
            #else
                let modelContainer = ModelContainer.shared
                logger.info("Startup in debug configuration. Target environment - unknown. didLoadData: \(didLoadData)")
                if didLoadData == false {
                    DefaultDataProvider.populateWithDefaultData(modelContainer: modelContainer)
                    didLoadData = true
                }
            #endif
        #else
            let modelContainer = ModelContainer.shared
            logger.info("Startup in NON debug configuration. Target environment - unknown. didLoadData: \(didLoadData)")
            if didLoadData == false {
                DefaultDataProvider.populateWithDefaultData(modelContainer: modelContainer)
                didLoadData = true
            }
        #endif
        return modelContainer
    }

    private func configureTips() {
        do {
//#if DEBUG
            do {
//                try Tips.resetDatastore()
            } catch {
                logger.log(level: .fault, "Failed to reset tips data store with error: \(error)")
            }
//            Tips.showAllTipsForTesting()
//#endif
            try Tips.configure([
                .datastoreLocation(.applicationDefault),
                .displayFrequency(.immediate),
            ])
        } catch {
            logger.log(level: .fault, "Failed to configure tips with error: \(error)")
        }
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
