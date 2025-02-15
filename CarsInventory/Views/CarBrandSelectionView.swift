//
//  MakeSelectionView.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-12.
//

import SwiftUI

struct CarBrandSelectionView: View {
    
    // MARK: - Section

    struct BrandSection: Identifiable {
        var id: UUID = UUID()
        
        var titleLetter: String
        var brands: [CarBrand]
    }
    
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedBrand: CarBrand?
    @State private var searchText = ""
    
    private let allSections: [BrandSection]
    private var filteredSections: [BrandSection] {
        guard searchText.isEmpty == false else {
            return allSections
        }
        
        return allSections.compactMap { section -> BrandSection? in
            let filteredBrands = section.brands.filter { brand in
                brand.displayName.lowercased().contains(searchText.lowercased())
            }
            
            if filteredBrands.isEmpty {
                return nil
            } else {
                return BrandSection(titleLetter: section.titleLetter, brands: filteredBrands)
            }
        }
    }
    
    // MARK: - Init
    
    init(selectedBrand: Binding<CarBrand?>? = nil) {
        self._selectedBrand = selectedBrand ?? Binding.constant(nil)
        
        let brandsMap = CarBrand.allCases.reduce(into: [String: [CarBrand]]()) { partialResult, carBrand in
            guard let firstCharacter = carBrand.displayName.first else {
                return
            }
            partialResult[String(firstCharacter).uppercased(), default: []].append(carBrand)
        }
        
        allSections = "abcdefghijklmnopqrstuvwxyz".compactMap { character -> BrandSection? in
            guard let brands = brandsMap[String(character).uppercased()] else {
                return nil
            }
            
            return BrandSection(titleLetter: String(character).uppercased(), brands: brands)
        }
    }
    
    // MARK: - View
    
    var body: some View {
        NavigationStack {
            List(filteredSections) { section in
                Section {
                    ForEach(section.brands) { brand in
                        Text(brand.displayName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedBrand = brand
                            }
                    }
                } header: {
                    Text(section.titleLetter)
                        .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 0))
                }
            }
            .navigationTitle("Car Brands")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .searchable(text: $searchText)
    }
    
}

// MARK: - Preview

#Preview {
    @Previewable @State var selectedBrand: CarBrand? = nil
    CarBrandSelectionView(selectedBrand: $selectedBrand)
}
