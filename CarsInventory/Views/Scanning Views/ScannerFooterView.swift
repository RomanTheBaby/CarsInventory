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
    @State private var selectedFranchise: Franchise?
    @State private var selectedYear: Int?
    @State private var selectedColor: ColorOption?
    @State private var selectedScale: InventoryCar.Scale?
    
    @State private var modelInput: String = ""
    @State private var seriesNumberInput: SeriesEntryNumber?
    
    @State private var showBrandSelectionView = false
    @State private var showModelInputView = false
    @State private var showSeriesSelectionView = false
    @State private var showSeriesNumberInputView = false
    @State private var showFranchiseSelectionView = false
    @State private var showYearInputView = false
    @State private var showColorInputView = false
    @State private var showScaleInputView = false
    
    @State private var animateAddToInventoryButton = false
    @State private var error: Error?
    @State private var carDuplicates: Int = 0
    
    @State private var isExpanded: Bool = false

    @Environment(\.modelsSuggestionProvider)
    private var modelsSuggestionProvider: ModelsSuggestionProvider

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
                    titleLabelWidth: 70,
                    selectedItem: $selectedBrand,
                    manualInputActionHandler: {
                        showBrandSelectionView = true
                    }
                ).frame(height: 40)
                
                SuggestionSelectionView(
                    title: "*Model: ",
                    items: viewModel.suggestion.models,
                    titleLabelWidth: 70,
                    selectedItem: $selectedMake,
                    manualInputActionHandler: {
                        showModelInputView = true
                    }
                ).frame(height: 40)
                
                SuggestionSelectionView(
                    title: "Series:  ",
                    items: viewModel.suggestion.series,
                    titleLabelWidth: 70,
                    selectedItem: $selectedSeries,
                    manualInputActionHandler: {
                        showSeriesSelectionView = true
                    },
                    selectionStatusChangeHandler: { isSelected, series in
                        if isSelected, let seriesFranchise = series.franchise {
                            viewModel.addSuggestedFranchise(seriesFranchise)
                        }
                        /// We want to update selected series to match franchise series, even if series has no franchise.
                        selectedFranchise = series.franchise
                    }
                ).frame(minHeight: 40)
                
                SuggestionSelectionView(
                    title: "Number:",
                    items: viewModel.suggestion.seriesNumber,
                    titleLabelWidth: 70,
                    selectedItem: $selectedSeriesNumber,
                    manualInputActionHandler: {
                        showSeriesNumberInputView = true
                    }
                ).frame(height: 40)
                
                if isExpanded {
                    SuggestionSelectionView(
                        title: "Franchise:",
                        items: viewModel.suggestion.franchises,
                        titleLabelWidth: 70,
                        selectedItem: $selectedFranchise,
                        manualInputActionHandler: {
                            showFranchiseSelectionView = true
                        }
                    ).frame(height: 40)
                    
                    SuggestionSelectionView(
                        title: "Year:",
                        items: viewModel.suggestion.years,
                        titleLabelWidth: 70,
                        selectedItem: $selectedYear,
                        manualInputActionHandler: {
                            showYearInputView = true
                        }
                    ).frame(height: 40)
                    
                    SuggestionSelectionView(
                        title: "Color:",
                        items: viewModel.suggestion.colors,
                        titleLabelWidth: 70,
                        selectedItem: $selectedColor,
                        manualInputActionHandler: {
                            showColorInputView = true
                        }
                    ).frame(height: 40)
                    
                    SuggestionSelectionView(
                        title: "Scale:",
                        items: viewModel.suggestion.scales,
                        titleLabelWidth: 70,
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
                ScalingButton(action: {
                    clearSelections()
                }, label: {
                    Image(systemName: "multiply.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(6)
                        .frame(width: 40, height: 40)
                })
                
                ScalingButton(action: {
                    viewModel.isScanning.toggle()
                    
                    if viewModel.isScanning {
                        clearSelections()
                    }
                    
                }, label: {
                    Image(systemName: viewModel.isScanning ? "stop.circle.fill" : "doc.text.viewfinder")
                        .resizable()
                        .scaledToFit()
                        .padding(6)
                        .frame(width: 40, height: 40)
                })
                
                ScalingButton(action: {
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
            }
            .frame(height: 40)
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
                        
                        if let seriesFranchise = newValue.franchise {
                            viewModel.addSuggestedFranchise(seriesFranchise)
                        }
                        /// We want to update selected series to match franchise series, even if series has no franchise.
                        selectedFranchise = newValue.franchise
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
        .sheet(isPresented: $showFranchiseSelectionView) {
            if let selectedFranchise {
                viewModel.addSuggestedFranchise(selectedFranchise)
                
                if let selectedSeries, selectedSeries.franchise != selectedFranchise {
                    self.selectedSeries = nil
                }
            }
        } content: {
            NavigationStack {
                FranchiseSelectionView(selection: $selectedFranchise)
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
                ModelInputView(brand: selectedBrand, input: $modelInput)
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
            if let series = selectedSeries,
               series.isUnknown == false,
               let selectedSeriesNumber,
               selectedSeriesNumber.total > (series.carsCount ?? 0) {
                series.updateCarsCount(selectedSeriesNumber.total)
            }
            
            if checkForDuplicates {
//                let duplicateCars = try fetchCar(for: selectedBrand, make: selectedMake, series: series)
//                if duplicateCars.isEmpty == false {
//                    carDuplicates = duplicateCars.count
//                    return
//                }
            }

            let inventoryCar = InventoryCar(
                brand: selectedBrand,
                make: selectedMake,
                series: selectedSeries,
                franchise: selectedFranchise,
                color: selectedColor ?? .unspecified,
                year: selectedYear,
                seriesEntryNumber: selectedSeriesNumber,
                scale: selectedScale,
                value: nil,
                note: nil
            )
            
            modelContext.insert(inventoryCar)
            modelsSuggestionProvider.recordModel(selectedMake, for: selectedBrand)
            if isInPreview == false {
                clearSelections()
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
    
    private func clearSelections() {
        selectedBrand = nil
        selectedMake = nil
        selectedSeries = nil
        selectedSeriesNumber = nil
        selectedFranchise = nil
        selectedYear = nil
        selectedColor = nil
        selectedScale = nil
        
        modelInput = ""
        seriesNumberInput = nil
        
        error = nil
        carDuplicates = 0
        
//        isExpanded = false
        
        viewModel.clearSuggestions()
    }
}

// MARK: - ScalingButton

private struct ScalingButton<Label> : View where Label : View {
    private var action: @MainActor () -> Void
    private var label: () -> Label
    
    @State private var scale = 1.0
    
    init(action: @escaping @MainActor () -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.action = action
        self.label = label
    }
    
    var body: some View {
        Button(
            action: {
                withAnimation(.easeOut(duration: 0.1)) {
                    scale = 0.9
                }
                        
                action()
                
                withAnimation(.easeOut(duration: 0.1).delay(0.1)) {
                    scale = 1.0
                }
            },
            label: label
        )
        .buttonStyle(.borderedProminent)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .scaleEffect(scale)
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
                    series: [CarsInventoryAppPreviewData.previewSeries[10]],
                    seriesNumber: [],
                    years: []
                ) ?? .empty
            )
        )
    }
    .modelContainer(CarsInventoryAppPreviewData.container)
}
