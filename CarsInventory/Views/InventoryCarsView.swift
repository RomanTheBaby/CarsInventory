//
//  InventoryCarsView.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-12.
//

import SwiftUI
import SwiftData

struct InventoryCarsView: View {
    
    // MARK: - CarBrandSection
    
    struct CarBrandSection: Identifiable {
        var id: UUID = UUID()
        
        var brand: CarBrand
        var cars: [InventoryCar]
    }
    
    // MARK: - Properties
    
    @Environment(\.modelContext) private var modelContext: ModelContext
    
    @State private var searchText = ""
    @State private var sections: [CarBrandSection] = []
    private let series: Series?
    private let title: String
    
    init(
        searchText: String = "",
        series: Series? = nil
    ) {
        self.searchText = searchText
        self.series = series
        
        if let series {
            title = series.displayName
        } else {
            title = "My Garage"
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if sections.isEmpty {
                emptyView
            } else {
                listView
            }
        }
        .navigationTitle(title)
        .onAppear(perform: reloadSections)
        .searchable(text: $searchText)
        .onChange(of: searchText) { _, _ in
            reloadSections()
        }
    }
    
    @ViewBuilder
    private var emptyView: some View {
        if searchText.isEmpty {
            VStack {
                if let series {
                    Text("You do not have anything in the \(series.fullName) yet.")
                        .multilineTextAlignment(.center)
                } else {
                    Text("You do not have any cars in the inventory yet.")
                        .multilineTextAlignment(.center)
                }
                Text("Scan a box with a car to add it to your inventory.")
                    .multilineTextAlignment(.center)
            }
        } else {
            Text("Nothing in inventory that would contain \"\(searchText)\"")
                .multilineTextAlignment(.center)
        }
    }
    
    private var listView: some View {
        List(sections) { section in
            Section {
                ForEach(section.cars) { car in
                    NavigationLink {
                        InventoryCarDetailView(inventoryCar: car)
                    } label: {
                        Text("\(car.brand.displayName) - \(car.make)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                }
            } header: {
                Text(section.brand.displayName)
                    .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 0))
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func reloadSections() {
        let fetchDescriptor: FetchDescriptor<InventoryCar>
        
        if let seriesId = series?.id {
            let predicate = #Predicate<InventoryCar> {
                $0.series.id == seriesId
            }
            fetchDescriptor = FetchDescriptor<InventoryCar>(predicate: predicate)
        } else {
            fetchDescriptor = FetchDescriptor<InventoryCar>()
        }
        
        let inventoryCars = (try? modelContext.fetch(fetchDescriptor)) ?? []
        
        let carsByBrands: [CarBrand: [InventoryCar]] = inventoryCars.reduce(into: [:]) { result, car in
            result[car.brand, default: []].append(car)
        }
        
        sections = Set(inventoryCars.map(\.brand)).sorted(by: { $0.displayName < $1.displayName })
            .compactMap { carBrand -> CarBrandSection? in
                guard let inventoryCars = carsByBrands[carBrand] else {
                    return nil
                }
                
                if searchText.isEmpty {
                    return CarBrandSection(brand: carBrand, cars: inventoryCars)
                } else {
                    let filteredCars = inventoryCars.filter { car in
                        car.make.lowercased().contains(searchText)
                            || car.brand.displayName.lowercased().contains(searchText)
                    }
                    
                    if !filteredCars.isEmpty {
                        return CarBrandSection(brand: carBrand, cars: filteredCars)
                    } else {
                        return nil
                    }
                }
            }
    }
}

// MARK: - Previews

#Preview("With series") {
    NavigationStack {
        InventoryCarsView()
            .modelContainer(CarsInventoryAppContainerSampleData.container)
    }
}

#Preview("With series") {
    NavigationStack {
        InventoryCarsView(series: CarsInventoryAppContainerSampleData.previewSeries[3])
            .modelContainer(CarsInventoryAppContainerSampleData.container)
    }
}
