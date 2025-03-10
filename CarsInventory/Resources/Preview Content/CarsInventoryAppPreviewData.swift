//
//  CarsInventoryAppPreviewData.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-04.
//

import Foundation
import SwiftData


actor CarsInventoryAppPreviewData {
    
    // MARK: - Public Properties
    
    @MainActor
    static let container: ModelContainer = {
        do {
            let schema = Schema([Series.self, InventoryCar.self, Franchise.self])
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            let modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            
            modelContainer.insertSeries()
            
            previewFranchises.forEach { franchise in
                modelContainer.mainContext.insert(franchise)
            }
            
            previewCars.forEach { series in
                modelContainer.mainContext.insert(series)
            }
            
            return modelContainer
        } catch {
            fatalError("Failed with error: \(error)")
        }
    }()
    
    @MainActor static let previewSeries: [Series] = {
        do {
            let seriesData = try DefaultDataProvider.hotWheelsSeriesData()
            let defaultSeries: [Series] = seriesData.enumerated().map { index, seriesData in
                Series(
                    id: "\(index)",
                    classification: Series.Classification(rawValue: seriesData.classification) ?? .regular,
                    displayName: seriesData.displayName,
                    alternativeNames: seriesData.alternativeNames,
                    year: seriesData.year,
                    carsCount: seriesData.carsCount,
                    cars: [],
                    franchise: previewFranchises[0]
                )
            }
            
            let unknowSeries = Series(id: AppConstants.Series.Unknown.id, classification: .regular, displayName: "Unknown")
            return defaultSeries + [unknowSeries]
        } catch {
            assertionFailure("Failed to load preview series data with error: \(error)")
            return []
        }
    }()
    
    @MainActor static let previewFranchises: [Franchise] = {
        [
            Franchise(id: "1", name: "Hot Wheels"),
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
        CarsInventoryAppPreviewData.previewSeries.forEach { series in
            mainContext.insert(series)
        }
    }
}
