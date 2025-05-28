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
            
            previewSeries.forEach(modelContainer.mainContext.insert(_:))
            previewCarBrands.forEach(modelContainer.mainContext.insert(_:))
            previewFranchises.forEach(modelContainer.mainContext.insert(_:))
            previewCars.forEach(modelContainer.mainContext.insert(_:))
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
    
    @MainActor static let previewCarBrands: [CarBrand] = {
        do {
            return try DefaultDataProvider.getAllCarBrands()
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
        let carBrands = previewCarBrands
        return [
            InventoryCar(
                id: "1",
                brand: carBrands.first(where: { $0.name == "PORSCHE" })!,
                model: "911 TURBO",
                series: previewSeries.first(where: { $0.displayName == "CYBERPUNK 2077" })!
            ),
            InventoryCar(
                id: "2",
                brand: carBrands.first(where: { $0.name == "LANCIA" })!,
                model: "Stratos",
                series: previewSeries[2]
            ),
            InventoryCar(
                id: "3",
                brand: carBrands.first(where: { $0.name == "FORD" })!,
                model: "MUSTANG GTD",
                series: previewSeries.first(where: { $0.displayName == "Mustang 60" })!,
                color: .gray
            ),
            
            InventoryCar(
                id: "4",
                brand: carBrands.first(where: { $0.name == "TOYOTA" })!,
                model: "Supra",
                series: previewSeries.first(where: { $0.displayName == "Fast & Furious: Brian O'Conner" })!,
                color: .orange
            ),
            InventoryCar(
                id: "5",
                brand: carBrands.first(where: { $0.name == "TOYOTA" })!,
                model: "Supra",
                series: previewSeries.first(where: { $0.displayName == "Fast & Furious: Brian O'Conner" })!,
                color: .white
            ),
            InventoryCar(
                id: "6",
                brand: carBrands.first(where: { $0.name == "MITSUBISHI" })!,
                model: "Eclipse",
                series: previewSeries.first(where: { $0.displayName == "Fast & Furious: Brian O'Conner" })!,
                color: .green,
                year: 1995
            ),
            InventoryCar(
                id: "6",
                brand: carBrands.first(where: { $0.name == "FORD" })!,
                model: "Escort RS1600",
                series: previewSeries.first(where: { $0.displayName == "Fast & Furious: Brian O'Conner" })!,
                color: .blue,
                year: 1970
            ),
            InventoryCar(
                id: "6",
                brand: carBrands.first(where: { $0.name == "FORD" })!,
                model: "Escort RS1600",
                series: previewSeries.first(where: { $0.displayName == "Fast & Furious: Brian O'Conner" })!,
                color: .blue,
                year: 1970
            ),
        ]
    }()
}
