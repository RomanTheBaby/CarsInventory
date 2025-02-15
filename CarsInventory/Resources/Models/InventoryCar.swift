//
//  InventoryCar.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-26.
//

import Foundation
import SwiftData

@Model
class InventoryCar: Identifiable, Hashable, CustomStringConvertible {
    // MARK: - Properties
    
    @Attribute(.unique)
    private(set) var id: String
    
    @Transient
    var brand: CarBrand {
        CarBrand(rawValue: rawBrand)!
    }
    
    @Transient
    var color: ColorOption {
        ColorOption(rawValue: rawColor)!
    }
    
    private var rawBrand: String
    private var rawColor: String
    private(set) var make: String
    
//    @Relationship(inverse: \Series.cars)
    private(set) var series: Series
    private(set) var year: Int?
    private(set) var value: Decimal?
    private(set) var note: String?
    
    @Transient
    var description: String {
        """
        InventoryCar(id: \(id), \
        brand: \(brand), \
        make: \(make), \
        series: \(series), \
        color: \(color)
        year: \(year?.description ?? "nil"), \
        value: \(value?.description ?? "nil"), \
        note: \(note ?? "nil"))
        """
    }
    
    // MARK: - Init
    
    init(
        id: String = UUID().uuidString,
        brand: CarBrand,
        make: String,
        series: Series,
        color: ColorOption = .unspecified,
        year: Int? = nil,
        value: Decimal? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.rawBrand = brand.rawValue
        self.make = make
        self.series = series
        self.rawColor = color.rawValue
        self.year = year
        self.value = value
        self.note = note
    }
    
    // MARK: - Update Helper Methods
    
    func updateBrand(_ newBrand: CarBrand) {
        rawBrand = newBrand.rawValue
    }
    
    func updateMake(_ newMake: String) {
        make = newMake
    }
    
    func updateSeries(_ newSeries: Series) {
        series = newSeries
    }
    
    func updateColor(_ newColor: ColorOption) {
        rawColor = newColor.rawValue
    }
    
    func updateYear(_ newYear: Int?) {
        year = newYear
    }
    
    func updateValue(_ newValue: Decimal?) {
        value = newValue
    }
    
    func updateNote(_ newNote: String?) {
        note = newNote
    }
}

