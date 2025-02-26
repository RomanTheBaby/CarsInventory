//
//  InventoryCarsListView.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-12.
//

import SwiftUI
import SwiftData

struct InventoryCarsListView: View {
    
    // MARK: - CarBrandSection
    
    struct CarBrandSection: Identifiable, Hashable {
        var id: UUID = UUID()
        
        var brand: CarBrand
        var cars: [InventoryCar]
    }
    
    // MARK: - Properties
    
    @Environment(\.modelContext) private var modelContext: ModelContext
    
    @State private var searchText = ""
    @State private var carsCount: Int = 0
    @State private var sections: [CarBrandSection] = []
    
    private let franchise: Franchise?
    private let series: Series?
    private let title: String
    
    // MARK: - Init
    
    init(
        searchText: String = "",
        series: Series? = nil
    ) {
        self.searchText = searchText
        self.series = series
        self.franchise = nil
        
        if let series {
            title = series.displayName
        } else {
            title = "My Garage"
        }
    }
    
    init(
        searchText: String = "",
        franchise: Franchise
    ) {
        self.searchText = searchText
        self.series = nil
        self.franchise = franchise
        
        title = franchise.displayName
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if sections.isEmpty {
                emptyView
                    .padding(.horizontal)
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
                if let displayName = series?.displayName ?? franchise?.displayName {
                    Text("You do not have anything in the \"\(displayName)\" yet.")
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
                        LabeledContent {
                            Text("")
                        } label: {
                            Text("\(car.brand.displayName) - \(car.make)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            Text("Series: \(car.series.displayName)")
                                .font(.footnote)
                        }
                    }
                }
            } header: {
                Text(section.brand.displayName)
                    .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 0))
            } footer: {
                if sections.isEmpty || section == sections[sections.count - 1] {
                    Text("Total: \(carsCount)")
                        .font(.footnote)
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                }
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
        } else if let franchiseId = franchise?.id {
            let predicate = #Predicate<InventoryCar> {
                $0.franchise?.id == franchiseId
            }
            fetchDescriptor = FetchDescriptor<InventoryCar>(predicate: predicate)
        } else {
            fetchDescriptor = FetchDescriptor<InventoryCar>()
        }
        
        let inventoryCars = (try? modelContext.fetch(fetchDescriptor)) ?? []
        
        let carsByBrands: [CarBrand: [InventoryCar]] = inventoryCars.reduce(into: [:]) { result, car in
            result[car.brand, default: []].append(car)
        }
        
        var totalCarsCount: Int = 0
        sections = Set(inventoryCars.map(\.brand)).sorted(by: { $0.displayName < $1.displayName })
            .compactMap { carBrand -> CarBrandSection? in
                guard var inventoryCars = carsByBrands[carBrand] else {
                    return nil
                }
                
                inventoryCars = inventoryCars.sorted(by: { $0.make < $1.make })
                
                if searchText.isEmpty == false {
                    let filteredCars = inventoryCars.filter { car in
                        car.make.lowercased().contains(searchText)
                            || car.brand.displayName.lowercased().contains(searchText)
                    }
                    inventoryCars = filteredCars
                }
                
                if inventoryCars.isEmpty {
                    return nil
                }
                
                totalCarsCount += inventoryCars.count
                return CarBrandSection(brand: carBrand, cars: inventoryCars)
            }
        carsCount = totalCarsCount
    }
}

// MARK: - Previews

#Preview("Without series") {
    NavigationStack {
        InventoryCarsListView()
            .modelContainer(CarsInventoryAppPreviewData.container)
    }
}

#Preview("With series") {
    NavigationStack {
        InventoryCarsListView(series: CarsInventoryAppPreviewData.previewSeries[3])
            .modelContainer(CarsInventoryAppPreviewData.container)
    }
}

#Preview("With Franchise") {
    NavigationStack {
        InventoryCarsListView(franchise: CarsInventoryAppPreviewData.previewFranchises[0])
            .modelContainer(CarsInventoryAppPreviewData.container)
    }
}
