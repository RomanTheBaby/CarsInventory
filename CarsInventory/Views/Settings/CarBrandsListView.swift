//
//  CarBrandsListView.swift
//  CarsInventory
//
//  Created by Roman on 2025-05-11.
//

import SwiftData
import SwiftUI

struct CarBrandsListView: View {
    
    @Query private var brands: [CarBrand]
    @StateObject private var viewModel = CarBrandListViewModel()
    
    var body: some View {
        List(viewModel.sections) { section in
            Section {
                ForEach(section.brands) { brand in
                    NavigationLink {
                        InventoryCarsListView(filterOption: .carBrand(brand))
                    } label: {
                        VStack {
                            Text(brand.displayName)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(brand.cars.count) car(s)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.footnote)
                                .fontWeight(.light)
                        }
                    }
                }
            } header: {
                Text(section.titleLetter)
                    .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 0))
            } footer: {
                if viewModel.sections.isEmpty || section == viewModel.sections[viewModel.sections.count - 1] {
                    Text("Total: \(viewModel.totalBrandsCount)")
                        .font(.footnote)
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                }
            }
        }
        .navigationTitle("Makes")
        .searchable(text: $viewModel.searchText)
        .onChange(of: viewModel.debouncedSearchText, { _, newValue in
            viewModel.updateSections(for: newValue, brands: brands)
        })
        .onAppear {
            viewModel.updateSections(for: viewModel.searchText, brands: brands)
        }
    }
}

