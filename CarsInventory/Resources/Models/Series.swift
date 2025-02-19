//
//  Series.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-04.
//

import Foundation
import SwiftData

@Model
class Series: Hashable, CustomStringConvertible {
    // MARK: - Classification
    
    enum Classification: String, Hashable, Codable, CaseIterable {
        case premium
        case regular
        
        var displayName: String {
            switch self {
            case .premium:
                return "Premium"
            case .regular:
                return "Regular"
            }
        }
    }
    
    private struct AlternativeName: Codable {
        var name: String
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
    private var alternativeNames: [AlternativeName] = []
    
    @Relationship(deleteRule: .cascade, inverse: \InventoryCar.series)
    private(set) var cars: [InventoryCar] = []
    
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
    
    @Transient
    var description: String {
        """
        Series(
            id: \(id), \
            classification: \(classification), \
            displayName: \(displayName) \
            alternativeNames: \(alternativeNames.map(\.name)) \
            year: \(year?.description ?? "No year") \
            totalCars: \(cars.count) \
            cars: \(cars)
        )
        """
    }
    
    // MARK: - Init
    
    init(
        id: String,
        classification: Classification,
        displayName: String,
        alternativeNames: [String] = [],
        year: Int? = nil,
        carsCount: Int? = nil,
        cars: [InventoryCar] = []
    ) {
        self.id = id
        self.classification = classification
        self.displayName = displayName
        self.alternativeNames = alternativeNames.map(AlternativeName.init(name:))
        self.year = year
        self.cars = cars
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
