//
//  SeriesSelectionView.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-13.
//


import SwiftUI
import SwiftData

struct SeriesSelectionView: View {

    // MARK: - Properties
    
    private let title: String
    private var showDismissButton: Bool = true
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedSeries: Series?
    @Query private var series: [Series]
    
    @StateObject private var viewModel = SeriesSelectionViewModel()

    // MARK: - Init
    
    init(
        title: String = "Select Series",
        showDismissButton: Bool = true,
        selectedSeries: Binding<Series?>? = nil
    ) {
        self.title = title
        self.showDismissButton = showDismissButton
        self._selectedSeries = selectedSeries ?? Binding.constant(nil)
    }
    
    // MARK: - Body
    
    var body: some View {
        List {
            if viewModel.seriesList.isEmpty {
                NavigationLink(value: "Add") {
                    Label("Add Custom", systemImage: "plus")
                }
            } else {
                Section {
                    ForEach(viewModel.seriesList) { series in
                        SeriesRow(series: series)
                            .onTapGesture {
                                selectedSeries = series
                            }
                    }
                } footer: {
                    Text("Total: \(viewModel.seriesList.count)")
                        .font(.footnote)
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                }
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: showDismissButton ? .topBarLeading : .topBarTrailing) {
                NavigationLink(value: "Add") {
                    Label("Add", systemImage: "plus")
                }
            }
            
            if showDismissButton {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText)
        .toolbarVisibility(.visible, for: .navigationBar)
        .navigationDestination(for: String.self) { view in
            if view == "Add" {
                SeriesCreationView(series: $selectedSeries, name: viewModel.searchText)
            }
        }
        .onChange(of: viewModel.debouncedSearchText, { _, newValue in
            viewModel.updateDisplayedItems(for: newValue, series: series)
        })
        .onAppear {
            viewModel.updateDisplayedItems(for: viewModel.searchText, series: series)
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selectedSeries: Series? = nil
    NavigationStack {
        SeriesSelectionView(showDismissButton: false, selectedSeries: $selectedSeries)
            .modelContainer(CarsInventoryAppPreviewData.container)
    }
}
