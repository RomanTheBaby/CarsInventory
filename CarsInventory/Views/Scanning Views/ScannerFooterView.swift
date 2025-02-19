//
//  ScannerFooterView.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-05.
//

import SwiftUI
import SwiftData

// MARK: - ScannerFooterView

struct ScannerFooterView: View {
    
    @ObservedObject var viewModel: ScanningViewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedBrand: CarBrand?
    @State private var selectedMake: String?
    @State private var selectedSeries: Series?
    @State private var selectedSeriesNumber: SeriesEntryNumber?
    @State private var selectedYear: Int?
    @State private var selectedColor: ColorOption?
    @State private var selectedScale: InventoryCar.Scale?
    
    @State private var modelInput: String = ""
    @State private var seriesNumberInput: SeriesEntryNumber?
    
    @State private var showBrandSelectionView = false
    @State private var showModelInputView = false
    @State private var showSeriesSelectionView = false
    @State private var showSeriesNumberInputView = false
    @State private var showYearInputView = false
    @State private var showColorInputView = false
    @State private var showScaleInputView = false
    
    @State private var animateAddToInventoryButton = false
    @State private var error: Error?
    @State private var carDuplicates: Int = 0
    
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack {
            
            Color.secondary
                .frame(width: 100, height: 8)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }
                .padding(.bottom)
            
            VStack {
                SuggestionSelectionView(
                    title: "*Make:  ",
                    items: viewModel.suggestion.brands,
                    selectedItem: $selectedBrand,
                    manualInputActionHandler: {
                        showBrandSelectionView = true
                    }
                ).frame(height: 40)
                
                SuggestionSelectionView(
                    title: "*Model: ",
                    items: viewModel.suggestion.models,
                    selectedItem: $selectedMake,
                    manualInputActionHandler: {
                        showModelInputView = true
                    }
                ).frame(height: 40)
                
                SuggestionSelectionView(
                    title: "Series:  ",
                    items: viewModel.suggestion.series,
                    selectedItem: $selectedSeries,
                    manualInputActionHandler: {
                        showSeriesSelectionView = true
                    }
                ).frame(height: 40)
                
                SuggestionSelectionView(
                    title: "Number:",
                    items: viewModel.suggestion.seriesNumber,
                    selectedItem: $selectedSeriesNumber,
                    manualInputActionHandler: {
                        showSeriesNumberInputView = true
                    }
                ).frame(height: 40)
                
                if isExpanded {
                    SuggestionSelectionView(
                        title: "Year:",
                        items: viewModel.suggestion.years ?? [],
                        selectedItem: $selectedYear,
                        manualInputActionHandler: {
                            showYearInputView = true
                        }
                    ).frame(height: 40)
                    
                    SuggestionSelectionView(
                        title: "Color:",
                        items: viewModel.suggestion.colors ?? [],
                        selectedItem: $selectedColor,
                        manualInputActionHandler: {
                            showColorInputView = true
                        }
                    ).frame(height: 40)
                    
                    SuggestionSelectionView(
                        title: "Scale:",
                        items: viewModel.suggestion.scales ?? [],
                        selectedItem: $selectedScale,
                        manualInputActionHandler: {
                            showScaleInputView = true
                        }
                    ).frame(height: 40)
                }
                
            }.frame(maxWidth: .infinity)

            Spacer()
                .frame(height: 16)
            
            HStack(spacing: 16) {
                Button(action: {
                    viewModel.clearSuggestions()
                }, label: {
                    Image(systemName: "multiply.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(6)
                        .frame(width: 40, height: 40)
                })
                .buttonStyle(.borderedProminent)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Button(action: {
                    viewModel.isScanning.toggle()
                    
                    if viewModel.isScanning {
                        viewModel.clearSuggestions()
                    }
                    
                }, label: {
                    Image(systemName: viewModel.isScanning ? "stop.circle.fill" : "doc.text.viewfinder")
                        .resizable()
                        .scaledToFit()
                        .padding(6)
                        .frame(width: 40, height: 40)
                })
                .buttonStyle(.borderedProminent)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Button(action: {
                    guard animateAddToInventoryButton == false else {
                        return
                    }

                    addCarToInventory(checkForDuplicates: false)
                    
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
                        HStack(spacing: -8) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(6)
                            Text("Add to inventory")
                                .frame(maxWidth: .infinity)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 4)
                        .frame(height: 40)
                    }
                })
                .buttonStyle(.borderedProminent)
                .disabled(selectedBrand == nil || selectedMake == nil)
                .frame(height: 50)
            }
        }
        .padding()
        .background(Color(uiColor: UIColor.systemBackground)) //Color(red: 229 / 255, green: 229 / 255, blue: 229 / 255))
        .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height < 0, isExpanded == false {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded = true
                        }
                    } else if isExpanded == true {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded = false
                        }
                    }
                }
        )
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
        .sheet(isPresented: $showModelInputView) {
            if modelInput.isEmpty == false {
                viewModel.addSuggestedModel(modelInput)
                selectedMake = modelInput
            }
            modelInput = ""
        } content: {
            NavigationStack {
                ModelInputView(input: $modelInput)
            }
        }
        .sheet(isPresented: $showSeriesNumberInputView) {
            if let seriesNumberInput {
                selectedSeriesNumber = seriesNumberInput
                viewModel.addSuggestedSeriesEntryNumber(seriesNumberInput)
            }
            seriesNumberInput = nil
        } content: {
            NavigationStack {
                CarSeriesNumberInputView(output: $seriesNumberInput)
            }
        }
        .sheet(isPresented: $showYearInputView) {
            if let selectedYear {
                viewModel.addSuggestedYear(selectedYear)
            }
        } content: {
            NavigationStack {
                YearInputView(input: $selectedYear)
            }
        }
        .sheet(isPresented: $showColorInputView) {
            if let selectedColor {
                viewModel.addSuggestedColor(selectedColor)
            }
        } content: {
            NavigationStack {
                ColorInputView(selection: $selectedColor)
            }
        }
        .sheet(isPresented: $showScaleInputView) {
            if let selectedScale {
                print(">>>LOLOLO: ", selectedScale)
                viewModel.addSuggestedScale(selectedScale)
            }
        } content: {
            NavigationStack {
                ScaleInputView(selection: $selectedScale)
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
            
            if series.isUnknown == false,
               let selectedSeriesNumber,
               selectedSeriesNumber.total > (series.carsCount ?? 0) {
                series.updateCarsCount(selectedSeriesNumber.total)
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
                series: series,
                seriesEntryNumber: selectedSeriesNumber
            )
            
            modelContext.insert(inventoryCar)
            if isInPreview == false {
                viewModel.clearSuggestions()
            }

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
            let unknownSeriesId = AppConstants.Series.Unknown.id
            let predicate = #Predicate<Series> { $0.id == unknownSeriesId }
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
