//
//  SeriesListView.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-11.
//

import SwiftUI
import SwiftData

struct SeriesListView: View {
    
    private enum RowItem: Identifiable {
        case unknownSeries
        case series(Series)
        
        var id: String {
            switch self {
            case .unknownSeries:
                return "Unknown"
            case .series(let series):
                return series.id
            }
        }
        
        var displayName: String {
            switch self {
            case .unknownSeries:
                return "Unknown"
            case .series(let series):
                return series.displayName
            }
        }
        
        var allNames: Set<String> {
            switch self {
            case .unknownSeries:
                return ["Unknown"]
            case .series(let series):
                return series.allNames
            }
        }
    }

    // MARK: - Properties
    
    private var showAddNewButton: Bool = true
    private var showDismissButton: Bool = true
    private let title: String
    
    @State private var searchText = ""
    @Query(sort: \Series.displayName) private var series: [Series]
    
    @Environment(\.dismiss) private var dismiss
    
    private var rowItems: [RowItem] {
        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if searchText.isEmpty {
            return [RowItem.unknownSeries] + series.map(RowItem.series(_:))
        }
        
        let rowItems = series.filter {
            $0.allNames.contains(where: { $0.lowercased().contains(trimmedQuery.lowercased())
            })
        }.map(RowItem.series(_:))
        
        if RowItem.unknownSeries.allNames.contains(searchText) {
            return [RowItem.unknownSeries] + rowItems
        }
        
        return rowItems
    }
    
    // MARK: - Init
    
    init(
        title: String = "Search Series",
        showAddNewButton: Bool = true,
        showDismissButton: Bool = false
    ) {
        self.title = title
        self.showAddNewButton = showAddNewButton
        self.showDismissButton = showDismissButton
        self.searchText = searchText
    }
    
    // MARK: - Body
    
    var body: some View {
        List {
            if rowItems.isEmpty {
                NavigationLink {
                    SeriesCreationView(name: searchText)
                } label: {
                    Label("Add", systemImage: "plus")
                }
            } else {
                ForEach(rowItems) { rowItem in
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
            }
        }
        .navigationTitle(title)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .toolbarVisibility(.visible, for: .navigationBar)
        .toolbar {
            if showAddNewButton {
                ToolbarItem(placement: showDismissButton ? .topBarLeading : .topBarTrailing) {
                    NavigationLink {
                        SeriesCreationView(name: searchText)
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
