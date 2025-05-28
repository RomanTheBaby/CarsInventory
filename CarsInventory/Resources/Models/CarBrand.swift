//
//  CarBrand.swift
//  CarsInventory
//
//  Created by Roman on 2025-05-10.
//

import SwiftData

// MARK: - BrandModel

private struct BrandModel: Codable, Hashable {
    var name: String
}

// MARK: - BrandAlternativeName

private struct BrandAlternativeName: Codable, Hashable {
    var name: String
}

@Model
class CarBrand: Hashable, Identifiable, Equatable {
    // MARK: - Properties
    
    @Attribute(.unique)
    var id: Int
    var name: String
    var displayName: String
    @Relationship(deleteRule: .cascade, inverse: \InventoryCar.brand)
    var cars: [InventoryCar]
    
    @Transient
    var knownModels: [String] {
        brandModels.map(\.name)
    }
    
    @Transient
    var allNames: [String] {
        [name, displayName] + alternativeNames
    }
    
    @Transient
    var alternativeNames: [String] {
        brandAlternativeNames.map(\.name)
    }
    
    private var brandModels: [BrandModel]
    private var brandAlternativeNames: [BrandAlternativeName]
    
    // MARK: - Init
    
    init(
        id: Int,
        name: String,
        displayName: String,
        alternativeNames: [String] = [],
        cars: [InventoryCar] = [],
        knownModels: [String],
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.brandAlternativeNames = alternativeNames.map(BrandAlternativeName.init(name:))
        self.cars = cars
        self.brandModels = knownModels.map(BrandModel.init(name:))
    }
}
