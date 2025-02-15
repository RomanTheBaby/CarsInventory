//
//  ScannerFooterView.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-05.
//

import SwiftUI
import SwiftData

// MARK: - FooterSelectionItem

private protocol FooterSelectionItem: Equatable {
    var id: String { get }
    var displayName: String { get }
}

extension CarBrand: FooterSelectionItem {}
extension Series: FooterSelectionItem {}
extension ScanningSuggestion.Number: FooterSelectionItem {
    var id: String {
        displayName
    }
    
    var displayName: String {
        "\(current)/\(total)"
    }
}

extension String: FooterSelectionItem {
    var id: String {
        self
    }
    
    var displayName: String {
        self
    }
}

// MARK: - ScannerFooterView

struct ScannerFooterView: View {
    
    @ObservedObject var viewModel: ScanningViewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedBrand: CarBrand?
    @State private var selectedMake: String?
    @State private var selectedSeries: Series?
    @State private var selectedSeriesNumber: ScanningSuggestion.Number?
    
    @State private var showSeriesSelectionView = false
    @State private var showBrandSelectionView = false
    
    @State private var animateAddToInventoryButton = false
    @State private var error: Error?
    @State private var carDuplicates: Int = 0

    var body: some View {
        VStack {
            HStack {
//                Rectangle()
//                    .clipShape(RoundedRectangle(cornerRadius: 16))
//                    .frame(width: 100, height: 150)
                
                VStack(spacing: 8) {
                    SelectionRow(
                        title: "*Make:  ",
                        items: viewModel.suggestion.brands,
                        selectedItem: $selectedBrand,
                        manualInputActionHandler: {
                            showBrandSelectionView = true
                        }
                    ).frame(height: 40)
                    
                    SelectionRow(
                        title: "*Model: ",
                        items: viewModel.suggestion.models,
                        selectedItem: $selectedMake,
                        manualInputActionHandler: {
                            assertionFailure("Manual make adding is not supported yet")
                        }
                    ).frame(height: 40)
                    
                    SelectionRow(
                        title: "Series:  ",
                        items: viewModel.suggestion.series,
                        selectedItem: $selectedSeries,
                        manualInputActionHandler: {
                            showSeriesSelectionView = true
                        }
                    ).frame(height: 40)
                    
                    SelectionRow(
                        title: "Number:",
                        items: viewModel.suggestion.seriesNumber,
                        selectedItem: $selectedSeriesNumber,
                        manualInputActionHandler: {
                            assertionFailure("Manual number adding is not supported yet")
                        }
                    ).frame(height: 40)

                }.frame(maxWidth: .infinity)
            }

            HStack(spacing: 16) {
                Button(action: {
                    viewModel.clearSuggestions()
                }, label: {
                    Text("Clear")
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, maxHeight: 40)
                })
                .buttonStyle(.borderedProminent)
                
                Button(action: {
                    guard animateAddToInventoryButton == false else {
                        return
                    }

                    addCarToInventory()
                    
                    withAnimation(.easeIn(duration: 0.3)) {
                        animateAddToInventoryButton = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(.easeIn(duration: 0.3)) {
                            animateAddToInventoryButton = false
                        }
                    }

                }, label: {
                    if animateAddToInventoryButton {
                        Image(systemName: "checkmark.circle")
                            .frame(maxWidth: .infinity, maxHeight: 40)
                    } else {
                        Text("Add to inventory")
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, maxHeight: 40)
                    }
                })
                .buttonStyle(.borderedProminent)
                .disabled(selectedBrand == nil || selectedMake == nil)
            }
            
            Button(action: {
                viewModel.isScanning.toggle()
                
                if viewModel.isScanning {
                    viewModel.clearSuggestions()
                }
                
            }, label: {
                Text(viewModel.isScanning ? "Stop Scanning" : "Start Scanning")
                    .padding(.horizontal)
                    .frame(height: 30)
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(uiColor: UIColor.systemBackground)) //Color(red: 229 / 255, green: 229 / 255, blue: 229 / 255))
        .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
        .errorAlert(error: $error)
        .confirmationDialog("Are yous sure", isPresented: .constant(carDuplicates > 0), actions: {
            Button("Add Duplicate") {
                
            }
        }, message: {
            Text("This is a messago")
        })
        .sheet(isPresented: $showSeriesSelectionView) {
            NavigationStack {
                SeriesSelectionView(selectedSeries: $selectedSeries)
                    .onChange(of: selectedSeries, initial: false) { _, newValue in
                        guard let newValue else {
                            return
                        }
                        
                        viewModel.addSuggestedSeries(newValue)
                        showSeriesSelectionView = false
                    }
            }
        }
        .sheet(isPresented: $showBrandSelectionView) {
            CarBrandSelectionView(selectedBrand: $selectedBrand)
                .onChange(of: selectedBrand, initial: false) { _, newValue in
                    guard let newValue else {
                        return
                    }
                    
                    viewModel.addSuggestedBrand(newValue)
                    showBrandSelectionView = false
                }
        }
    }
    
    // MARK: - Helper Methods
    
    private func addCarToInventory(checkForDuplicates: Bool = true) {
        guard let selectedBrand, let selectedMake else {
            return
        }
        
        do {
            let series = if let selectedSeries {
                selectedSeries
            } else {
                try fetchUnknownSeries()
            }
            
            if checkForDuplicates {
                let duplicateCars = try fetchCar(for: selectedBrand, make: selectedMake, series: series)
                if duplicateCars.isEmpty == false {
                    carDuplicates = duplicateCars.count
                    return
                }
            }

            let inventoryCar = InventoryCar(
                brand: selectedBrand,
                make: selectedMake,
                series: series
            )
            
            modelContext.insert(inventoryCar)
            if isInPreview == false {
                viewModel.clearSuggestions()
            }

            print(">>>Should add to inventory: ", inventoryCar)
        } catch {
            self.error = error
        }
    }
    
    private func fetchCar(for brand: CarBrand, make: String, series: Series) throws -> [InventoryCar] {
        do {
            let predicate = #Predicate<InventoryCar> { car in
//                car.brand == brand && car.make == make && car.series == series
                car.make == make// && car.series == series
            }
            
            let fetchDescriptor = FetchDescriptor<InventoryCar>(predicate: predicate)
            return try modelContext.fetch(fetchDescriptor)
            
        } catch {
            assertionFailure("PLEASE FIX. Failed to fetch car for brand: \(brand), make: \(make) series \(series) with error: \(error).")
            throw error
        }
    }
    
    private func fetchUnknownSeries() throws -> Series {
        do {
            let predicate = #Predicate<Series> { $0.id == "-404" }
            var fetchDescriptor = FetchDescriptor<Series>(predicate: predicate)
            fetchDescriptor.fetchLimit = 1
            guard let unknownSeries = try modelContext.fetch(fetchDescriptor).first else {
                assertionFailure("PLEASE FIX. No unknown series In storage.")
                throw LocalizedErrorInfo(
                    failureReason: "Failed to assign unknown series when adding new car to the inventory",
                    errorDescription: "Make sure you have latest app version and try again",
                    recoverySuggestion: "Make sure you have latest app version and try again"
                )
            }
            
            return unknownSeries
        } catch {
            assertionFailure("PLEASE FIX. Failed to fetch unknown series with error: \(error).")
            throw error
        }
    }
}

// MARK: - SelectionRow

private struct SelectionRow<Item: FooterSelectionItem>: View {
    var title: String
    var items: [Item]
    
    @Binding var selectedItem: Item?

    var manualInputActionHandler: (() -> Void)
    
    var body: some View {
        HStack {
            Text(title)
                .frame(alignment: .leading)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(
                        items.sorted(by: { lhs, rhs in
                            lhs.displayName < rhs.displayName
                        }),
                        id: \.id
                    ) { item in
                        Button {
                            selectedItem = item
                        } label: {
                            Text(item.displayName)
                                .foregroundStyle(selectedItem == item ? .white : Color.primary)
                                .frame(minWidth: 50)
                                .padding(8)
                                .background(selectedItem == item ? .blue : Color(uiColor: .lightGray))
                                .cornerRadius(8)
                        }
                    }
                    
                    Button {
                        manualInputActionHandler()
                    } label: {
                        HStack(spacing: 0) {
                            Text("Enter manually | ")
                                .foregroundStyle(Color.primary)

                            Image(systemName: "plus")
                                .foregroundStyle(Color.primary)
                        }
                        .frame(minWidth: 50)
                        .padding(8)
                        .background(Color(uiColor: .lightGray))
                        .cornerRadius(8)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: -16) {
        Color.red
            .ignoresSafeArea(.all, edges: .top)
        ScannerFooterView(
            viewModel: ScanningViewModel(
                suggestion: ScanningSuggestion(
                    brands: [.bmw, .audi, .abarth],
                    models: ["Skyline"],
                    series: [],
                    seriesNumber: [],
                    years: []
                ) ?? .empty
            )
        )
    }
    .modelContainer(CarsInventoryAppContainerSampleData.container)
}
