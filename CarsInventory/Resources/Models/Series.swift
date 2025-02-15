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
    
    // MARK: - Properties
    
    @Attribute(.unique)
    private(set) var id: String
    
    private(set) var classification: Classification
    
    private(set) var fullName: String
    private(set) var displayName: String
    private(set) var year: Int?
    
    @Relationship(deleteRule: .cascade, inverse: \InventoryCar.series)
//    @Relationship(inverse: \InventoryCar.series)
    private(set) var cars: [InventoryCar] = []
    
    @Transient
    var allNames: Set<String> {
        Set<String>([fullName, displayName])
    }
    
    @Transient
    var description: String {
        """
        Series(
            id: \(id), \
            classification: \(classification), \
            fullName: \(fullName)) \
            displayName: \(displayName)
        )
        """
    }
    
    // MARK: - Init
    
    init(
        id: String,
        classification: Classification,
        fullName: String,
        displayName: String,
        year: Int? = nil,
        cars: [InventoryCar] = []
    ) {
        self.id = id
        self.classification = classification
        self.fullName = fullName
        self.displayName = displayName
        self.year = year
        self.cars = cars
    }
    
    // MARK: - Public Methods
    
    func updateClassification(_ newClassification: Classification) {
        self.classification = newClassification
    }
    
    func updateFullName(_ newFullName: String) {
        self.fullName = newFullName
    }
    
    func updateDisplayName(_ newDisplayName: String) {
        self.displayName = newDisplayName
    }
    
    func updateYear(_ newYear: Int?) {
        self.year = newYear
    }
    
}
