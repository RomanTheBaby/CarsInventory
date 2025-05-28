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
    private(set) var model: String
    
//    @Relationship(inverse: \Series.cars)
    private(set) var series: [Series]
    private(set) var franchise: Franchise?
    private(set) var year: Int?
    private(set) var seriesEntryNumber: SeriesEntryNumber?
    private(set) var scale: Scale?
    
    private(set) var value: Decimal?
    private(set) var note: String?
    
    @Transient
    var description: String {
        """
        InventoryCar(\
        id: \(id), \
        brand: \(brand), \
        model: \(model), \
        series: \(seriesDescription), \
        color: \(color), \
        year: \(year?.description ?? "nil"), \
        seriesEntryNumber: \(seriesEntryNumber?.description ?? "nothing")
        value: \(value?.description ?? "nil"), \
        note: \(note ?? "nil")\
        )
        """
    }
    
    @Transient
    private var seriesDescription: String {
        series.map {
            """
            \(String(describing: Series.self))(\
            id: \($0.id), \
            classification: \($0.classification), \
            displayName: \($0.displayName), \
            year: \($0.year?.description ?? "nil"),
            carsCount: \($0.carsCount?.description ?? "nil")\
            )
            """
        }.joined(separator: ", ")
    }
    
    // MARK: - Init
    
    init(
        id: String = UUID().uuidString,
        brand: CarBrand,
        model: String,
        series: Series?,
        franchise: Franchise?,
        color: ColorOption = .unspecified,
        year: Int? = nil,
        seriesEntryNumber: SeriesEntryNumber? = nil,
        scale: Scale? = nil,
        value: Decimal? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.brand = brand
        self.model = model
        self.series = if let series {
            [series]
        } else {
            []
        }
        self.franchise = franchise
        self.color = color
        self.year = year
        self.seriesEntryNumber = seriesEntryNumber
        self.value = value
        self.note = note
    }
    
    init(
        id: String = UUID().uuidString,
        brand: CarBrand,
        model: String,
        series: Series?,
        color: ColorOption = .unspecified,
        year: Int? = nil,
        seriesEntryNumber: SeriesEntryNumber? = nil,
        scale: Scale? = nil,
        value: Decimal? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.brand = brand
        self.model = model
        self.series = if let series {
            [series]
        } else {
            []
        }
//        let firstNonNilFranchise = series.first(where: { $0.franchise != nil  })?.franchise
//        self.franchise = series.contains(where: { $0.franchise != firstNonNilFranchise  }) ? nil : firstNonNilFranchise
        self.franchise = series?.franchise
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
    
    func updateModel(_ newModel: String) {
        model = newModel
    }
    
    func updateSeries(_ newSeries: Series) {
        series = [newSeries]
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
    var displayName: String {
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
