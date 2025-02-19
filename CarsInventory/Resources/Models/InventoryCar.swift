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
    // MARK: - Scale
    
    enum Scale: Int, Codable, CaseIterable {
        case scale1
        case scale12
        case scale18
        case scale24
        case scale32
        case scale43
        case scale64
        case scale87
    }
    
    // MARK: - Properties
    
    @Attribute(.unique)
    private(set) var id: String
    
    private(set) var brand: CarBrand
    private(set) var color: ColorOption
    private(set) var make: String
    
//    @Relationship(inverse: \Series.cars)
    private(set) var series: Series
    private(set) var year: Int?
    private(set) var seriesEntryNumber: SeriesEntryNumber?
    private(set) var scale: Scale?
    
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
            seriesEntryNumber: \(seriesEntryNumber?.description ?? "nothing")
            value: \(value?.description ?? "nil"), \
            note: \(note ?? "nil")
        )
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
        seriesEntryNumber: SeriesEntryNumber? = nil,
        scale: Scale? = nil,
        value: Decimal? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.brand = brand
        self.make = make
        self.series = series
        self.color = color
        self.year = year
        self.seriesEntryNumber = seriesEntryNumber
        self.value = value
        self.note = note
    }
    
    // MARK: - Update Helper Methods
    
    func updateBrand(_ newBrand: CarBrand) {
        brand = newBrand
    }
    
    func updateMake(_ newMake: String) {
        make = newMake
    }
    
    func updateSeries(_ newSeries: Series) {
        series = newSeries
    }
    
    func updateColor(_ newColor: ColorOption) {
        color = newColor
    }
    
    func updateYear(_ newYear: Int?) {
        year = newYear
    }
    
    func updateSeriesEntryNumber(_ newSeriesEntryNumber: SeriesEntryNumber?) {
        seriesEntryNumber = newSeriesEntryNumber
    }
    
    func updateScale(_ newScale: Scale?) {
        scale = newScale
    }
    
    func updateValue(_ newValue: Decimal?) {
        value = newValue
    }
    
    func updateNote(_ newNote: String?) {
        note = newNote
    }
}

extension InventoryCar.Scale {
    var description: String {
        switch self {
        case .scale1:
            "1/1"
        case .scale12:
            "1/12"
        case .scale18:
            "1/18"
        case .scale24:
            "1/24"
        case .scale32:
            "1/32"
        case .scale43:
            "1/43"
        case .scale64:
            "1/64"
        case .scale87:
            "1/87"
        }
    }
}
