//
//  ScanningSuggestion.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-06.
//

import Foundation

struct ScanningSuggestion: Hashable {
    // MARK: - Properties

    var brands: [CarBrand]
    var models: [String]
    var series: [Series]
    var seriesNumber: [Number]
    var years: [Int]?
    
    // MARK: - Number
    
    struct Number: Hashable {
        var current: Int
        var total: Int
    }
    
    // MARK: - Init
    
    init?(
        brands: [CarBrand],
        models: [String],
        series: [Series],
        seriesNumber: [Number],
        years: [Int]?
    ) {
        guard !brands.isEmpty || !brands.isEmpty || series.isEmpty || seriesNumber.isEmpty || (years ?? []).isEmpty else {
            return nil
        }

        self.brands = brands
        self.models = models
        self.series = series
        self.seriesNumber = seriesNumber
        self.years = years
    }
    
    private init() {
        self.brands = []
        self.models = []
        self.series = []
        self.seriesNumber = []
        self.years = []
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

    mutating func add(seriesNumber: [Number]) {
        let newSeriesNumber = self.seriesNumber + seriesNumber
        self.seriesNumber = newSeriesNumber.unique
    }

    mutating func add(years: [Int]) {
        let newYears = self.years ?? [] + years
        self.years = newYears.unique
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
