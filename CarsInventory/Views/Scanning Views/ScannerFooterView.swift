//
//  ScannerFooterView.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-05.
//

import OSLog
import SwiftUI
import SwiftData
import TipKit

// MARK: - ScannerFooterView

struct ScannerFooterView: View {
    // MARK: - Properties
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? String(describing: Self.self),
        category: String(describing: Self.self)
    )
    
    @ObservedObject var viewModel: ScanningViewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedBrand: CarBrand?
    @State private var selectedModel: String?
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
    
    private let scanningControlsExpansionTip = ScanningControlsExpansionTip()
    private let scanningControlsTip = ScanningControlsTip()
    
    // MARK: - Init
    
    init(viewModel: ScanningViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - View
    
    var body: some View {
        VStack {
            VStack {
                Color.secondary
                    .frame(width: 100, height: 8)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .onTapGesture {
                        scanningControlsExpansionTip.invalidate(reason: .actionPerformed)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }
                
                TipView(scanningControlsExpansionTip, arrowEdge: .top)
            }.padding(.bottom)
            
            VStack {
                mainInputsView
                
                if isExpanded {
                    expandedInputsView
                }
                
            }.frame(maxWidth: .infinity)

            Spacer()
                .frame(height: 16)
            
            TipView(scanningControlsTip)
                .onChange(of: scanningControlsTip.status, { oldValue, newValue in
                    switch newValue {
                    case .available, .invalidated:
                        break
                    case .pending:
                        scanningControlsTip.invalidate(reason: .actionPerformed)
                    @unknown default:
                        print("Unknown status: \(newValue)")
                    }
                    
                })
                .padding(.bottom, 16)
            
            mainControlsView
                .frame(height: 40)
        }
        .padding()
        .background(Color(uiColor: UIColor.systemBackground)) //Color(red: 229 / 255, green: 229 / 255, blue: 229 / 255))
        .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height < 0, isExpanded == false {
                        scanningControlsExpansionTip.invalidate(reason: .actionPerformed)
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
                selectedModel = modelInput
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
    
    var mainInputsView: some View {
        Group {
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
                selectedItem: $selectedModel,
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
            
            if isExpanded == false, viewModel.suggestion.years.isEmpty == false {
                yearInputView
            }
            
            if isExpanded == false, viewModel.suggestion.scales.isEmpty == false {
                scaleInputView
            }
        }
    }
    
    private var expandedInputsView: some View {
        Group {
            SuggestionSelectionView(
                title: "Franchise:",
                items: viewModel.suggestion.franchises,
                titleLabelWidth: 70,
                selectedItem: $selectedFranchise,
                manualInputActionHandler: {
                    showFranchiseSelectionView = true
                }
            ).frame(height: 40)
            
            yearInputView
            scaleInputView

            SuggestionSelectionView(
                title: "Color:",
                items: viewModel.suggestion.colors,
                titleLabelWidth: 70,
                selectedItem: $selectedColor,
                manualInputActionHandler: {
                    showColorInputView = true
                }
            ).frame(height: 40)
        }
    }
    
    private var yearInputView: some View {
        SuggestionSelectionView(
            title: "Year:",
            items: viewModel.suggestion.years,
            titleLabelWidth: 70,
            selectedItem: $selectedYear,
            manualInputActionHandler: {
                showYearInputView = true
            }
        ).frame(height: 40)
    }
    
    private var scaleInputView: some View {
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
    
    private var mainControlsView: some View {
        HStack(spacing: 16) {
            ScalingButton(action: {
                ScanningControlsTip.didUseControls.sendDonation()
                clearSelections()
            }, label: {
                Image(systemName: "multiply.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(6)
                    .frame(width: 40, height: 40)
            })
            
            ScalingButton(action: {
                ScanningControlsTip.didUseControls.sendDonation()
                
                viewModel.isScanning.toggle()
                
                if viewModel.isScanning {
                    clearSelections()
                }
                
            }, label: {
                Image(systemName: viewModel.isScanning ? "stop.circle.fill" : "play")
                    .resizable()
                    .scaledToFit()
                    .padding(6)
                    .frame(width: 40, height: 40)
            })
            
            ScalingButton(action: {
                ScanningControlsTip.didUseControls.sendDonation()
                guard animateAddToInventoryButton == false, selectedBrand != nil, selectedModel != nil else {
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
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
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
            .disabled(selectedBrand == nil || selectedModel == nil)
        }
    }
    
    // MARK: - Helper Methods
    
    private func addCarToInventory(checkForDuplicates: Bool = true) {
        guard let selectedBrand, let selectedModel else {
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
//                let duplicateCars = try fetchCar(for: selectedBrand, model: selectedModel, series: series)
//                if duplicateCars.isEmpty == false {
//                    carDuplicates = duplicateCars.count
//                    return
//                }
            }

            let inventoryCar = InventoryCar(
                brand: selectedBrand,
                model: selectedModel,
                series: selectedSeries,
                franchise: selectedFranchise,
                color: selectedColor ?? .unspecified,
                year: selectedYear,
                seriesEntryNumber: selectedSeriesNumber,
                scale: selectedScale,
                value: nil,
                note: nil
            )
            
            logger.info("Did add car to inventory: \(inventoryCar)")
            
            modelContext.insert(inventoryCar)
            modelsSuggestionProvider.recordModel(selectedModel, for: selectedBrand)
            if isInPreview == false {
                clearSelections()
            }

        } catch {
            self.error = error
        }
    }
    
    private func fetchCar(for brand: CarBrand, model: String, series: Series) throws -> [InventoryCar] {
        do {
            let predicate = #Predicate<InventoryCar> { car in
//                car.brand == brand && car.model == model && car.series == series
                car.model == model// && car.series == series
            }
            
            let fetchDescriptor = FetchDescriptor<InventoryCar>(predicate: predicate)
            return try modelContext.fetch(fetchDescriptor)
            
        } catch {
            assertionFailure("PLEASE FIX. Failed to fetch car for brand: \(brand), model: \(model) series \(series) with error: \(error).")
            throw error
        }
    }
    
    private func clearSelections() {
        selectedBrand = nil
        selectedModel = nil
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
                    brands: Array(CarsInventoryAppPreviewData.previewCarBrands.prefix(5)),
                    models: ["Skyline", "159"],
                    series: [CarsInventoryAppPreviewData.previewSeries[10]],
                    seriesNumber: [],
                    years: []
                ) ?? .empty
            )
        )
    }
    .modelContainer(CarsInventoryAppPreviewData.container)
}

#Preview("Tips") {
    VStack(spacing: -16) {
        Color.red
            .ignoresSafeArea(.all, edges: .top)
        ScannerFooterView(
            viewModel: ScanningViewModel(
                suggestion: ScanningSuggestion(
                    brands: Array(CarsInventoryAppPreviewData.previewCarBrands.prefix(5)),
                    models: ["Skyline", "159"],
                    series: [CarsInventoryAppPreviewData.previewSeries[10]],
                    seriesNumber: [],
                    years: []
                ) ?? .empty
            )
        )
    }
    .modelContainer(CarsInventoryAppPreviewData.container)
    .task {
        try? Tips.resetDatastore()
        Tips.showAllTipsForTesting()
    }
}
