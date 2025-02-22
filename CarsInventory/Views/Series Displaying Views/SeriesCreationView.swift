//
//  SeriesCreationView.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-11.
//

import SwiftUI
import SwiftData

struct SeriesCreationView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var modelContext: ModelContext
    
    @Query private var franchises: [Franchise]
    
    @Binding private var series: Series?
    
    @State private var name: String
    @State private var yearSelection: Int
    @State private var carsCount: Int?
    @State private var classificationSelection: Series.Classification = .regular
    @State private var franchise: Franchise?
    
    @State private var isPresentingConfirmAlert = false
    @State private var error: Error?
    
    private let shouldAutoDismiss: Bool
    
    // MARK: - Init
    
    init(series: Series) {
        self._series = Binding.constant(series)
        name = series.displayName
        yearSelection = series.year ?? 0
        carsCount = series.carsCount
        classificationSelection = series.classification
        
        shouldAutoDismiss = true
    }
    
    init(series: Binding<Series?>? = nil, name: String? = nil) {
        self._series = series ?? Binding.constant(nil)
        self.name = name ?? series?.wrappedValue?.displayName ?? ""
        self.yearSelection = series?.wrappedValue?.year ?? 0
        self.carsCount = series?.wrappedValue?.carsCount
        self.classificationSelection = series?.wrappedValue?.classification ?? .regular
        
        self.shouldAutoDismiss = series == nil
    }
    
    // MARK: - Body
    
    var body: some View {
        Form {
            requiredInformationSection
            optionalInformationSection
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .navigationTitle(series == nil ? "Create series" : "Update series")
        .overlay(alignment: .bottom) {
            creationCTAView
        }
        .errorAlert(error: $error)
        .confirmationDialog("You already have a series that contains \(name)", isPresented: $isPresentingConfirmAlert) {
            Button("Create new", role: .destructive) {
                handleSeriesAction(checkForDuplicates: false)
            }
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You already have a series with matching name and classification. Are you sure you want to create new series with this name?")
        }
    }
    
    private var requiredInformationSection: some View {
        Section {
            LabeledContent {
                TextField("Series Name", text: $name)
                    .multilineTextAlignment(.trailing)
            } label: {
                Text("Series name")
                Text("Required")
                    .font(.footnote)
            }
            
            Picker("Classification", selection: $classificationSelection) {
                ForEach(Series.Classification.allCases, id: \.rawValue) { classification in
                    Text(classification.rawValue.capitalized)
                        .tag(classification)
                }
            }
            
        } header: {
            Text("Required information")
                .listRowInsets(EdgeInsets())
                .padding(.vertical, 8)
        }
    }
    
    private var optionalInformationSection: some View {
        Section {
            YearPickerView(minYear: 1968, reverseOrder: true, selection: $yearSelection) {
                Text("Series Year")
                Text("Optional")
                    .font(.footnote)
            }
            
            Picker(selection: Binding($franchise, deselectTo: nil)) {
                ForEach(franchises) { franchise in
                    Text(franchise.name)
                        .tag(franchise as Franchise?) // This is required for binding to work
                }
            } label: {
                Text("Franchise")
                Text("optional")
                    .font(.footnote)
            } currentValueLabel: {
                Text(franchise?.name ?? "Unspecified")
            }

            LabeledContent {
                TextField("Number", value: $carsCount, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            } label: {
                Text("Number of cars in series")
                Text("Optional")
                    .font(.footnote)
            }
        } header: {
            Text("Additional information")
                .listRowInsets(EdgeInsets())
                .padding(.vertical, 8)
        }
    }
    
    private var creationCTAView: some View {
        Button {
            guard name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
                return
            }
            
            handleSeriesAction()
        } label: {
            Text(series == nil ? "Create new series" : "Update series")
                .padding(.horizontal)
                .frame(height: 50)
        }
        .buttonStyle(.borderedProminent)
        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    // MARK: - Private Methods
    
    private func handleSeriesAction(checkForDuplicates: Bool = true) {
        if let series {
            series.updateDisplayName(name.trimmingCharacters(in: .whitespacesAndNewlines))
            series.updateClassification(classificationSelection)
            series.updateYear(yearSelection == 0 ? nil : yearSelection)
            
            if shouldAutoDismiss {
                dismiss()
            }
            
        } else {
            do {
                let allSeries = try getAllSeries()

                let hasDuplicates: Bool
                if checkForDuplicates {
                    let matchingSeries = allSeries.filter { series in
                        let namesSet = Set(series.allNames.map { $0.lowercased() })
                        return namesSet.contains(name.lowercased()) && series.classification == classificationSelection
                    }
                    hasDuplicates = matchingSeries.isEmpty == false
                } else {
                    hasDuplicates = false
                }

                if hasDuplicates {
                    isPresentingConfirmAlert = true
                } else {
                    let newSeries = Series(
                        id: "\(allSeries.count)",
                        classification: classificationSelection,
                        displayName: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        year: yearSelection == 0 ? nil : yearSelection,
                        carsCount: carsCount
                    )
                    modelContext.insert(newSeries)
                    series = newSeries
                }
                
                if shouldAutoDismiss {
                    dismiss()
                }
            } catch {
                self.error = error
            }
        }
    }
    
    private func getAllSeries() throws -> [Series] {
        let fetchDescriptor = FetchDescriptor<Series>()
        return try modelContext.fetch(fetchDescriptor)
    }
    
}

// MARK: - Binding Helper

private extension Binding where Value: Equatable {
    init(_ source: Binding<Value>, deselectTo value: Value) {
        self.init(
            get: {
                source.wrappedValue
            },
            set: {
                source.wrappedValue = $0 == source.wrappedValue ? value : $0
            }
        )
    }
}

// MARK: - Previews

#Preview("Creating New Series") {
    @Previewable @State var createdSeries: Series? = nil
    SeriesCreationView(series: $createdSeries)
        .modelContainer(CarsInventoryAppPreviewData.container)
}

#Preview("Updating existing series") {
    SeriesCreationView(series: CarsInventoryAppPreviewData.previewSeries[3])
        .modelContainer(CarsInventoryAppPreviewData.container)
}
