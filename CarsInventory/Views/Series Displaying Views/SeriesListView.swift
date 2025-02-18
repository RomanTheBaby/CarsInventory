//
//  SeriesListView.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-11.
//

import SwiftUI
import SwiftData

struct SeriesListView: View {

    // MARK: - Properties
    
    private var showAddNewButton: Bool = true
    private var showDismissButton: Bool = true
    private let title: String
    
    @State private var searchText = ""
    @Query private var series: [Series]
    
    @Environment(\.dismiss) private var dismiss
    
    private var searchResults: [Series] {
        series.filter {
            searchText.isEmpty ? true : $0.fullName.lowercased().contains(searchText.lowercased())
        }.sorted { lhs, rhs in
            if lhs.isUnknown || rhs.isUnknown {
                return lhs.isUnknown
            }
            
            return lhs.fullName < rhs.fullName
        }
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
            if searchResults.isEmpty {
                NavigationLink {
                    SeriesCreationView(name: searchText)
                } label: {
                    Label("Add", systemImage: "plus")
                }

            } else {
                ForEach(searchResults) { series in
                    NavigationLink {
                        SeriesCarsView(series: series)
                    } label: {
                        SeriesRow(series: series)
                    }
                }
            }
        }
        .navigationTitle(title)
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
        .searchable(text: $searchText)
        .toolbarVisibility(.visible, for: .navigationBar)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selectedSeries: Series? = nil
    NavigationStack {
        SeriesListView()
            .modelContainer(CarsInventoryAppContainerSampleData.container)
    }
}
