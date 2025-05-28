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
    
    // MARK: - FilterOption
    
    enum FilterOption {
        case none
        case carBrand(CarBrand)
        case franchise(Franchise)
        case series(Series)
        case unknownSeries
    }
    
    // MARK: - Properties
    
    @Environment(\.modelContext) private var modelContext: ModelContext
    
    @State private var searchText = ""
    @State private var carsCount: Int = 0
    @State private var sections: [CarBrandSection] = []
    
    private let title: String
    private let franchise: Franchise?
    private let filterOption: FilterOption
    
    // MARK: - Init
    
    init(searchText: String = "", filterOption: FilterOption = .none) {
        self.searchText = searchText
        self.filterOption = filterOption
        self.franchise = nil
        
        switch filterOption {
        case .none:
            title = "My Garage"
        case .franchise(let franchise):
            title = franchise.displayName
        case .series(let series):
            title = series.displayName
        case .carBrand(let brand):
            title = brand.displayName
        case .unknownSeries:
            title = "Unknown"
        }
    }
    
    init(searchText: String = "", series: Series) {
        self.init(searchText: searchText, filterOption: .series(series))
    }
    
    init(searchText: String = "", franchise: Franchise) {
        self.init(searchText: searchText, filterOption: .franchise(franchise))
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
                switch filterOption {
                case .none:
                    Text("You do not have any cars in the inventory yet.")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                case .franchise(let franchise):
                    Text("You do not have anything for the \"\(franchise.displayName)\" franchise yet.")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                case .series(let series):
                    Text("You do not have anything in the \"\(series.displayName)\" series yet.")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                case .carBrand(let brand):
                    Text("You do not have anything for the \"\(brand.displayName)\" yet.")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                case .unknownSeries:
                    Text("You do not have any cars in the \"Unknown\" series yet.")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                }
                Text("Scan a box with a car to add it to your inventory.")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
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
                        CarInfoRow(car: car)
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
        
        switch filterOption {
        case .none:
            fetchDescriptor = FetchDescriptor<InventoryCar>()
            
        case .series(let series):
            let seriesId = series.id
            let predicate = #Predicate<InventoryCar> {
                $0.series.contains(where: { $0.id == seriesId })
            }
            fetchDescriptor = FetchDescriptor<InventoryCar>(predicate: predicate)
            
        case .franchise(let franchise):
            let franchiseId = franchise.id
            let predicate = #Predicate<InventoryCar> {
                $0.franchise?.id == franchiseId
            }
            fetchDescriptor = FetchDescriptor<InventoryCar>(predicate: predicate)
            
        case .carBrand(let brand):
            let brandId = brand.id
            let predicate = #Predicate<InventoryCar> {
                $0.brand.id == brandId
            }
            fetchDescriptor = FetchDescriptor<InventoryCar>(predicate: predicate)
            
        case .unknownSeries:
            let predicate = #Predicate<InventoryCar> {
                $0.series.isEmpty
            }
            fetchDescriptor = FetchDescriptor<InventoryCar>(predicate: predicate)
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
                
                inventoryCars = inventoryCars.sorted(by: { $0.model < $1.model })
                
                if searchText.isEmpty == false {
                    let filteredCars = inventoryCars.filter { car in
                        car.model.lowercased().contains(searchText)
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

private struct CarInfoRow: View, Equatable {
    var car: InventoryCar
    
    var body: some View {
        LabeledContent {
            Text("")
        } label: {
            Text("\(car.brand.displayName) - \(car.model)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            if car.series.isEmpty {
                Text("Series: Unknown")
                    .font(.footnote)
            } else {
                Text("Series(\(car.series.count)): \(Set(car.series.map(\.displayName)).sorted().joined(separator: ", "))")
                    .font(.footnote)
            }
        }
    }
    
    static func == (lhs: CarInfoRow, rhs: CarInfoRow) -> Bool {
        lhs.car.brand.displayName == rhs.car.brand.displayName
            && lhs.car.series.map(\.displayName) == rhs.car.series.map(\.displayName)
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

#Preview("Unknown series") {
    NavigationStack {
        InventoryCarsListView(filterOption: .unknownSeries)
            .modelContainer(CarsInventoryAppPreviewData.container)
    }
}

#Preview("With Franchise") {
    NavigationStack {
        InventoryCarsListView(franchise: CarsInventoryAppPreviewData.previewFranchises[0])
            .modelContainer(CarsInventoryAppPreviewData.container)
    }
}
