//
//  CarBrandListViewModel.swift
//  CarsInventory
//
//  Created by Roman on 2025-05-11.
//

import Combine
import Foundation
import SwiftData

class CarBrandListViewModel: ObservableObject {
    // MARK: - Section

    struct BrandSection: Identifiable, Equatable {
        var id: UUID = UUID()
        
        var titleLetter: String
        var brands: [CarBrand]
    }
    
    // MARK: - Properties
    
    @Published var searchText: String
    @Published private(set) var debouncedSearchText = ""
    
    @Published private(set) var totalBrandsCount: Int = 0
    @Published private(set) var sections: [BrandSection] = []
    
    // MARK: - Init
    
    init(searchText: String = "") {
        self.searchText = searchText
        self.debouncedSearchText = searchText
        
        $searchText
            .debounce(for: .seconds(0.33), scheduler: RunLoop.main)
            .assign(to: &$debouncedSearchText)
    }
    
    func updateSections(for query: String, brands: [CarBrand]) {
        let filteredBrands: [CarBrand] = query.isEmpty ? brands : brands.filter {
            $0.allNames.contains(where: { $0.lowercased().contains(query.lowercased()) })
        }
        
        guard filteredBrands.isEmpty == false else {
            sections = []
            return
        }
        
        let brandsMap = filteredBrands.reduce(into: [String: [CarBrand]]()) { partialResult, carBrand in
            guard let firstCharacter = carBrand.displayName.first else {
                return
            }
            partialResult[String(firstCharacter).uppercased(), default: []].append(carBrand)
        }
        
        sections = "abcdefghijklmnopqrstuvwxyz".compactMap { character -> BrandSection? in
            guard let brands = brandsMap[String(character).uppercased()] else {
                return nil
            }
            
            return BrandSection(titleLetter: String(character).uppercased(), brands: brands)
        }
        totalBrandsCount = filteredBrands.count
    }
}
