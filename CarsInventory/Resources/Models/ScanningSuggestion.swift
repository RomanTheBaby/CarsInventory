//
//  ScanningSuggestion.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-06.
//

import Foundation

struct SeriesEntryNumber: Hashable, Codable, CustomStringConvertible {
    var current: Int
    var total: Int
    
    var description: String {
        "SeriesEntryNumber(current: \(current), total: \(total))"
    }
}

struct ScanningSuggestion: Hashable {
    // MARK: - Properties

    var brands: [CarBrand]
    var models: [String]
    var series: [Series]
    var seriesNumber: [SeriesEntryNumber]
    var years: [Int]?
    var colors: [ColorOption]?
    var scales: [InventoryCar.Scale]?
    
    // MARK: - Init
    
    init?(
        brands: [CarBrand],
        models: [String],
        series: [Series],
        seriesNumber: [SeriesEntryNumber],
        years: [Int]? = nil,
        colors: [ColorOption]? = nil,
        scales: [InventoryCar.Scale]? = nil
    ) {
        guard !brands.isEmpty || !brands.isEmpty || series.isEmpty || seriesNumber.isEmpty || (years ?? []).isEmpty else {
            return nil
        }

        self.brands = brands
        self.models = models
        self.series = series
        self.seriesNumber = seriesNumber
        self.years = years
        self.colors = colors
        self.scales = scales
    }
    
    private init() {
        brands = []
        models = []
        series = []
        seriesNumber = []
        years = nil
        colors = nil
        scales = nil
    }
    
    static let empty: Self = .init()
    
    // MARK: - Public Methods
    
    mutating func add(brands: [CarBrand]) {
        let newBrands = self.brands + brands
        self.brands = newBrands.unique
    }

    mutating func add(models: [String]) {
        let newModels = self.models + models
        self.models = newModels.unique
    }

    mutating func add(series: [Series]) {
        let newSeries = self.series + series
        self.series = newSeries.unique
    }

    mutating func add(seriesNumber: [SeriesEntryNumber]) {
        let newSeriesNumber = self.seriesNumber + seriesNumber
        self.seriesNumber = newSeriesNumber.unique
    }

    mutating func add(years: [Int]) {
        let newYears = (self.years ?? []) + years
        self.years = newYears.unique
    }
    
    mutating func add(colors: [ColorOption]) {
        let newColors = (self.colors ?? []) + colors
        self.colors = newColors.unique
    }
    
    mutating func add(scales: [InventoryCar.Scale]) {
        let newScales = (self.scales ?? []) + scales
        self.scales = newScales.unique
    }
}

private extension Array where Element: Hashable {
    var unique: [Element] {
        var existingElements: Set<Element> = Set([])
        
        return self.filter { element in
            if existingElements.contains(element) {
                return false
            }
            
            existingElements.insert(element)
            return true
        }
    }
}
