//
//  CarsInventoryAppContainerSampleData.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-04.
//

import Foundation
import SwiftData

actor CarsInventoryAppContainerSampleData {
    
    // MARK: - Public Properties
    
    @MainActor
    static let container: ModelContainer = {
        do {
            let schema = Schema([Series.self])
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            let modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            
            modelContainer.insertSeries()
            
            previewCars.forEach { series in
                modelContainer.mainContext.insert(series)
            }
            
            return modelContainer
        } catch {
            fatalError("Failed with error: \(error)")
        }
    }()
    
    @MainActor static let previewSeries: [Series] = {
        [
            Series(id: "1", classification: .premium, fullName: "HW Race Day", displayName: "RACE DAY"),
            Series(id: "2", classification: .regular, fullName: "Factory Fresh", displayName: "Factory Fresh"),
            Series(id: "3", classification: .regular, fullName: "Then and Now", displayName: "Then and Now", year: 2024),
            Series(id: "4", classification: .regular, fullName: "MUSTANG 60™", displayName: "MUSTANG 60™", year: 2025),
            Series(id: AppConstants.Series.Unknown.id, classification: .regular, name: "Unknown"),
        ]
    }()
    
    @MainActor static let previewCars: [InventoryCar] = {
        [
            InventoryCar(id: "1", brand: .porsche, make: "911 TURBO", series: previewSeries[1]),
            InventoryCar(id: "2", brand: .dodge, make: "CHALLENGER", series: previewSeries[2]),
            InventoryCar(id: "3", brand: .ford, make: "MUSTANG GTD", series: previewSeries[3], color: .gray),
            InventoryCar(id: "4", brand: .porsche, make: "Panamera", series: previewSeries[previewSeries.count - 1]),
        ]
    }()
}

extension ModelContainer {
    @MainActor func insertSeries() {
        CarsInventoryAppContainerSampleData.previewSeries.forEach { series in
            mainContext.insert(series)
        }
    }
}
