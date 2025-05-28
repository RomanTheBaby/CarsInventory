//
//  MakeSelectionView.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-12.
//

import SwiftData
import SwiftUI

struct CarBrandSelectionView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedBrand: CarBrand?
    @Query private var brands: [CarBrand]
    @StateObject private var viewModel = CarBrandListViewModel()
    
    // MARK: - Init
    
    init(selectedBrand: Binding<CarBrand?>? = nil) {
        self._selectedBrand = selectedBrand ?? Binding.constant(nil)
    }
    
    // MARK: - View
    
    var body: some View {
        NavigationStack {
            List(viewModel.sections) { section in
                Section {
                    ForEach(section.brands) { brand in
                        HStack {
                            Text(brand.displayName)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            
                            if let selectedBrand, brand == selectedBrand {
                                Image(systemName: "checkmark")
                            }
                        }
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
            .onChange(of: viewModel.debouncedSearchText, { _, newValue in
                viewModel.updateSections(for: newValue, brands: brands)
            })
            .onAppear {
                viewModel.updateSections(for: viewModel.searchText, brands: brands)
            }
        }
        .searchable(text: $viewModel.searchText)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selectedBrand: CarBrand? = nil
    CarBrandSelectionView(selectedBrand: $selectedBrand)
        .modelContainer(CarsInventoryAppPreviewData.container)
}

#Preview("with selected brand") {
    @Previewable @State var selectedBrand: CarBrand? = CarsInventoryAppPreviewData.previewCarBrands[4]
    CarBrandSelectionView(selectedBrand: $selectedBrand)
        .modelContainer(CarsInventoryAppPreviewData.container)
}
