//
//  ModelsSuggestionProvider.swift
//  CarsInventory
//
//  Created by Roman on 2025-03-10.
//

import Foundation

class ModelsSuggestionProvider {
    // MARK: - Constants
    
    private enum Constants {
        static let storageKey = "com.CarsInventory.ModelsCache"
    }
    
    // MARK: - Private Properties
    
    private var modelsCache: [String: [String]]
    
    // MARK: - Init
    
    init() {
        modelsCache = UserDefaults.standard
            .value(forKey: Constants.storageKey) as? [String: [String]] ?? [:]
    }
    
    // MARK: - Public Methods
    
    func recordModel(_ model: String, for brand: CarBrand) {
        var existingModels = modelsCache[brand.storageKey] ?? []
        guard Set(existingModels).contains(model) == false else {
            return
        }
        
        existingModels.append(model)
        modelsCache[brand.storageKey] = existingModels

        UserDefaults.standard.set(modelsCache, forKey: Constants.storageKey)
    }
    
    func suggestions(for brand: CarBrand, query: String = "") -> [String] {
        modelsCache[brand.storageKey] ?? []
    }
}

private extension CarBrand {
    var storageKey: String {
        rawValue
    }
}
