//
//  Series.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-04.
//

import Foundation
import SwiftData

private struct SeriesAlternativeName: Codable {
    var name: String
}

@Model
class Series: Hashable, CustomStringConvertible {
    // MARK: - Classification
    
    enum Classification: String, Hashable, Codable, CaseIterable {
        case premium
        case regular
        case silver
        
        var displayName: String {
            rawValue.capitalized
        }
    }
    
    // MARK: - Properties
    
    @Attribute(.unique)
    private(set) var id: String
    
    private(set) var classification: Classification
    
    private(set) var displayName: String
    /// Number of cars in a series. NOT number of cars linked to the series
    private(set) var carsCount: Int?
    private(set) var year: Int?
    
    /// list of names that can be user to lookup the series. i.e during scan.
    private var alternativeNames: [SeriesAlternativeName] = []
    
    @Relationship(inverse: \InventoryCar.series)
    private(set) var cars: [InventoryCar] = []
    
    @Relationship(inverse: \Franchise.series)
    private(set) var franchise: Franchise?
    
    @Transient
    var allNames: Set<String> {
        let names = Set<String>([displayName] + alternativeNames.map(\.name))
        let trademarkNames = Set<String>(names.map { $0 + "™" })
        return names.union(trademarkNames)
    }
    
    @Transient
    var isUnknown: Bool {
        id == AppConstants.Series.Unknown.id
    }
    
//    @Transient
//    var description: String {
//        """
//        Series(
//        id: \(id), \
//        classification: \(classification), \
//        displayName: \(displayName), \
//        alternativeNames: \(alternativeNames), \ // printing this cases errors for some reason
//        year: \(year?.description ?? "No year"), \
//        totalCars: \(cars.count), \
//        cars: \(cars)\
//        )
//        """
//    }
    
    @Transient
    var description: String {
        """
        Series(
        id: \(id), \
        classification: \(classification), \
        displayName: \(displayName), \
        year: \(year?.description ?? "No year"), \
        totalCars: \(cars.count), \
        cars: \(cars)\
        )
        """
    }
    
    @Transient
    private var carsDescription: String {
        cars.map { car in
            """
            \(String(describing: InventoryCar.self))(\
            id: \(car.id), \
            brand: \(car.brand.displayName), \
            model: \(car.model), \
            year: \(car.year?.description ?? "nil"),
            SeriesEntryNumber: \(car.seriesEntryNumber?.description ?? "nil")\
            )
            """
        }.joined(separator: ", ")
    }
    
    // MARK: - Init
    
    init(
        id: String,
        classification: Classification,
        displayName: String,
        alternativeNames: [String] = [],
        year: Int? = nil,
        carsCount: Int? = nil,
        cars: [InventoryCar] = [],
        franchise: Franchise? = nil
    ) {
        self.id = id
        self.classification = classification
        self.displayName = displayName
        self.alternativeNames = alternativeNames.map(SeriesAlternativeName.init(name:))
        self.year = year
        self.cars = cars
        self.franchise = franchise
    }
    
    // MARK: - Public Methods
    
    func updateClassification(_ newClassification: Classification) {
        self.classification = newClassification
    }
    
    func updateDisplayName(_ newDisplayName: String) {
        self.displayName = newDisplayName
    }
    
    func updateYear(_ newYear: Int?) {
        self.year = newYear
    }
    
    func updateCarsCount(_ newCarsCount: Int?) {
        self.carsCount = newCarsCount
    }
    
}
