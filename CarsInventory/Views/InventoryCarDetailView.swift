//
//  InventoryCarDetailView.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-14.
//

import SwiftUI
import SwiftData

struct InventoryCarDetailView: View {
    
    // MARK: - Properties
    
    private(set) var inventoryCar: InventoryCar
    
    @State private var brand: CarBrand
    @State private var brandSelection: CarBrand?
    @State private var make: String
    @State private var carColor: ColorOption
    @State private var yearSelection: Int
    @State private var value: Decimal?
    @State private var seriesEntryNumber: SeriesEntryNumber?
    @State private var scale: InventoryCar.Scale?
    
    @State private var series: Series?
    @State private var seriesSelection: Series?
    
    @State private var showSeriesSelection: Bool = false
    @State private var showBrandSelectionView: Bool = false
    @State private var showDeleteConfirmationDialog: Bool = false
    @State private var showSeriesNumberInputView: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext: ModelContext
    
    // MARK: - Init
    
    init(inventoryCar: InventoryCar) {
        self.inventoryCar = inventoryCar
        self.brand = inventoryCar.brand
        self.make = inventoryCar.make
        self.carColor = inventoryCar.color
        self.yearSelection = inventoryCar.year ?? 0
        self._series = State(initialValue: inventoryCar.series.first)
        /// Initializing state object explicitly, as otherwise it is not persistig after init for some reason :(
        self._seriesEntryNumber = State(initialValue: inventoryCar.seriesEntryNumber)
        self._scale = State(initialValue: inventoryCar.scale)
        self._value = State(initialValue: inventoryCar.value)
    }
    
    // MARK: - Body
    
    var body: some View {
        Form {
            Section {
                LabeledContent {
                    Button {
                        showBrandSelectionView = true
                    } label: {
                        Text(brand.displayName)
                    }
                } label: {
                    Text("Car Brand")
                    Text("Required")
                        .font(.footnote)
                }
                
                LabeledContent {
                    TextField("Model", text: $make)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Text("Model")
                    Text("Required")
                        .font(.footnote)
                }
            } header: {
                Text("Required information")
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical, 8)
            }
            
            Section {
                LabeledContent {
                    Button {
                        showSeriesSelection = true
                    } label: {
                        Text(series?.displayName ?? "Unknown")
                    }
                } label: {
                    Text("Series")
                    Text("Optional")
                        .font(.footnote)
                }
                
                Picker(selection: $carColor) {
                    ForEach(ColorOption.allCases, id: \.self) {
                        Text($0.displayName)
                    }
                } label: {
                    Text("Car color")
                    Text("optional")
                        .font(.footnote)
                }
                
                YearPickerView(minYear: 1886, reverseOrder: true, selection: $yearSelection) {
                    Text("Car Year")
                    Text("Optional")
                        .font(.footnote)
                }
                
                LabeledContent {
                    Button {
                        showSeriesNumberInputView = true
                    } label: {
                        if let seriesEntryNumber = seriesEntryNumber ?? inventoryCar.seriesEntryNumber {
                            Text("\(seriesEntryNumber.current) out of \(seriesEntryNumber.total)")
                        } else {
                            Text("Unknown")
                        }
                    }
                } label: {
                    Text("Number in series")
                    Text("optional")
                        .font(.footnote)
                }
                
                Picker(selection: $scale) {
                    ForEach(InventoryCar.Scale.allCases, id: \.self) {
                        Text($0.displayName)
                            .tag($0 as InventoryCar.Scale?) // This is required for binding to work
                    }
                } label: {
                    Text("Scale")
                    Text("optional")
                        .font(.footnote)
                } currentValueLabel: {
                    Text(scale?.displayName ?? "Unspecified")
                }

                LabeledContent {
                    TextField("Value", value: $value, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numbersAndPunctuation)
                } label: {
                    Text("Value")
                    Text("optional")
                        .font(.footnote)
                }
            } header: {
                Text("Optional information")
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical, 8)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                guard make.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
                    return
                }
                
                handleSeriesUpdateAction()
            } label: {
                Text("Update car information")
                    .padding(.horizontal)
                    .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            .disabled(make.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.bottom, 8)
        }
        .sheet(isPresented: $showBrandSelectionView) {
            CarBrandSelectionView(selectedBrand: $brandSelection)
                .onChange(of: brandSelection, initial: false) { _, newValue in
                    guard let newValue else {
                        return
                    }
                    
                    brand = newValue
                    showBrandSelectionView = false
                }
        }
        .sheet(isPresented: $showSeriesSelection) {
            NavigationStack {
                SeriesSelectionView(selectedSeries: $seriesSelection)
                    .onChange(of: seriesSelection, initial: false) { _, newValue in
                        guard let newValue else {
                            return
                        }
                        series = newValue
                        showSeriesSelection = false
                    }
            }
        }
        .sheet(isPresented: $showSeriesNumberInputView) {
            NavigationStack {
                CarSeriesNumberInputView(output: $seriesEntryNumber)
            }
        }
        .confirmationDialog("Are you sure?", isPresented: $showDeleteConfirmationDialog) {
            Button("Delete", role: .destructive) {
                modelContext.delete(inventoryCar)
                dismiss()
            }
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this car from your inventory? This action cannot be undone")
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showDeleteConfirmationDialog = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .navigationTitle("Update information")
    }
    
    // MARK: - Private Methods
    
    private func handleSeriesUpdateAction() {
        guard make.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return
        }
        
        inventoryCar.updateBrand(brand)
        inventoryCar.updateMake(make.trimmingCharacters(in: .whitespacesAndNewlines))
        if let series {
            inventoryCar.updateSeries(series)
        }
        inventoryCar.updateColor(carColor)
        inventoryCar.updateSeriesEntryNumber(seriesEntryNumber)
        inventoryCar.updateYear(yearSelection == 0 ? nil : yearSelection)
        inventoryCar.updateScale(scale)
        inventoryCar.updateValue(value)
            
        dismiss()
    }
}

#Preview {
    NavigationStack {
        InventoryCarDetailView(inventoryCar: CarsInventoryAppPreviewData.previewCars[2])
            .modelContainer(CarsInventoryAppPreviewData.container)
    }
}

#Preview("From car list view") {
    NavigationStack {
        InventoryCarsListView()
    }.modelContainer(CarsInventoryAppPreviewData.container)
}
