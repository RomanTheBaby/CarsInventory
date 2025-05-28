//
//  SeriesListView.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-11.
//

import SwiftUI
import SwiftData

struct SeriesListView: View {
    
    private typealias RowItem = SeriesListViewModel.RowItem

    // MARK: - Properties
    
    private var showAddNewButton: Bool = true
    private var showDismissButton: Bool = true
    private let title: String
    
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = SeriesListViewModel()
    @Query(sort: \Series.displayName) private var series: [Series]
    
    
    // MARK: - Init
    
    init(
        title: String = "Search Series",
        showAddNewButton: Bool = true,
        showDismissButton: Bool = false
    ) {
        self.title = title
        self.showAddNewButton = showAddNewButton
        self.showDismissButton = showDismissButton
    }
    
    // MARK: - Body
    
    var body: some View {
        List {
            if viewModel.rowItems.isEmpty {
                NavigationLink {
                    SeriesCreationView(name: viewModel.searchText)
                } label: {
                    Label("Add", systemImage: "plus")
                }
            } else {
                Section {
                    ForEach(viewModel.rowItems) { rowItem in
                        NavigationLink {
                            switch rowItem {
                            case .series(let series):
                                SeriesCarsView(series: series)
                                
                            case .unknownSeries:
                                InventoryCarsListView(filterOption: .unknownSeries)
                            }
                        } label: {
                            switch rowItem {
                            case .series(let series):
                                SeriesRow(series: series)
                                
                            case .unknownSeries:
                                Text(rowItem.displayName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                } footer: {
                    Text("Total: \(viewModel.rowItems)")
                        .font(.footnote)
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                }
            }
        }
        .navigationTitle(title)
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
        .toolbarVisibility(.visible, for: .navigationBar)
        .toolbar {
            if showAddNewButton {
                ToolbarItem(placement: showDismissButton ? .topBarLeading : .topBarTrailing) {
                    NavigationLink {
                        SeriesCreationView(name: viewModel.searchText)
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
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
        .onChange(of: viewModel.debouncedSearchText, { _, newValue in
            viewModel.updateRowItems(for: newValue, series: series)
        })
        .onAppear {
            viewModel.updateRowItems(for: viewModel.searchText, series: series)
        }
    }
}

private struct SeriesCarsView: View {
    
    var series: Series
    
    var body: some View {
        InventoryCarsListView(series: series)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SeriesCreationView(series: series)
                    } label: {
                        Text("Edit Series")
                    }
                }
            }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selectedSeries: Series? = nil
    NavigationStack {
        SeriesListView()
            .modelContainer(CarsInventoryAppPreviewData.container)
    }
}
