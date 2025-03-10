//
//  DefaultDataProvider.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-22.
//

import Foundation
import SwiftData
import OSLog

actor DefaultDataProvider {
    // MARK: - SeriesData
    
    struct SeriesData: Codable {
        var classification: String
        var displayName: String
        var alternativeNames: [String]
        var year: Int? = nil
        var carsCount: Int? = nil
    }
    
    // MARK: - Properties
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? String(describing: DefaultDataProvider.self),
        category: String(describing: DefaultDataProvider.self)
    )
    
    // MARK: - Public Methods
    
    @MainActor
    static func populateWithDefaultData(modelContainer: ModelContainer) {
        logger.trace("Will load default data")
        populateHotWheelsData(for: modelContainer)
    }
    
    @MainActor
    static func hotWheelsSeriesData() throws -> [SeriesData] {
        let decoder = JSONDecoder()
        
        guard let seriesFileURL = Bundle.main.url(forResource: "HotWheelsSeries", withExtension: "json") else {
            logger.critical("Failed to get url for HotWheelsSeries.json")
            throw LocalizedErrorInfo(failureReason: "Failed to load default series")
        }
        
        let seriesFileData = try Data(contentsOf: seriesFileURL)
        return try decoder.decode([SeriesData].self, from: seriesFileData)
    }
    
    // MARK: - Private Methods
    
    @MainActor private static func populateHotWheelsData(for modelContainer: ModelContainer) {
        let franchise = Franchise(id: "1", name: "Hot Wheels")
        modelContainer.mainContext.insert(franchise)
        
        do {
            let seriesData = try hotWheelsSeriesData()
            logger.trace("Did load \(seriesData.count) models for HotWheels series")
            let allSeries: [Series] = seriesData.enumerated().map { index, seriesData in
                Series(
                    id: "\(index)",
                    classification: Series.Classification(rawValue: seriesData.classification) ?? .regular,
                    displayName: seriesData.displayName,
                    alternativeNames: seriesData.alternativeNames,
                    year: seriesData.year,
                    carsCount: seriesData.carsCount,
                    cars: [],
                    franchise: franchise
                )
            }
            
//            let unknowSeries = Series(id: AppConstants.Series.Unknown.id, classification: .regular, displayName: "Unknown")
//            let allSeries = defaultSeries + [unknowSeries]
            allSeries.forEach(modelContainer.mainContext.insert(_:))
            
            logger.trace("Did create \(allSeries.count) series")
        } catch {
            logger.critical("Failed to loead default series with error: \(error)")
        }
    }
}
