//
//  ScanningViewModel.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-06.
//

import SwiftUICore

class ScanningViewModel: ObservableObject {
    
    // MARK: Public Properties
    
    @Published private(set) var suggestion: ScanningSuggestion
    
    @Published var isScanning: Bool = false
    
    // MARK: - Init
    
    init(suggestion: ScanningSuggestion = .empty) {
        self.suggestion = suggestion
    }
    
    // MARK: - Public Methods
    
    func update(from scanningSuggestion: ScanningSuggestion) {
        suggestion.add(brands: scanningSuggestion.brands)
        suggestion.add(models: scanningSuggestion.models)
        suggestion.add(series: scanningSuggestion.series)
        suggestion.add(seriesNumber: scanningSuggestion.seriesNumber)
        suggestion.add(years: scanningSuggestion.years)
        suggestion.add(colors: scanningSuggestion.colors)
        suggestion.add(franchises: scanningSuggestion.franchises)
        suggestion.add(scales: scanningSuggestion.scales)
    }
    
    func addSuggestedBrand(_ brand: CarBrand) {
        suggestion.add(brands: [brand])
    }
    
    func addSuggestedModel(_ model: String) {
        let trimmedModel = model.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedModel.isEmpty == false else {
            return
        }
        
        suggestion.add(models: [trimmedModel])
    }
    
    func addSuggestedSeries(_ series: Series) {
        suggestion.add(series: [series])
    }
    
    func addSuggestedSeriesEntryNumber(_ number: SeriesEntryNumber) {
        suggestion.add(seriesNumber: [number])
    }
    
    func addSuggestedYear(_ year: Int) {
        suggestion.add(years: [year])
    }
    
    func addSuggestedColor(_ color: ColorOption) {
        suggestion.add(colors: [color])
    }
    
    func addSuggestedScale(_ scale: InventoryCar.Scale) {
        suggestion.add(scales: [scale])
    }
    
    func addSuggestedFranchise(_ franchise: Franchise) {
        suggestion.add(franchises: [franchise])
    }
    
    func clearSuggestions() {
        suggestion = .empty
    }
}
