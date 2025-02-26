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
    
    private var showDismissButton: Bool = true
    private let title: String
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedSeries: Series?
    @State private var searchText = ""
    @Query private var series: [Series]
    
    private var searchResults: [Series] {
        let filteredSeries = searchText.isEmpty ? series : series.filter { series in
            series.allNames.contains(where: { $0.lowercased().contains(searchText.lowercased()) })
        }
        
        return filteredSeries
            .sorted { lhs, rhs in
                if lhs.isUnknown || rhs.isUnknown {
                    return lhs.isUnknown
                }
                
                return lhs.displayName < rhs.displayName
            }
    }
    
    // MARK: - Init
    
    init(
        title: String = "Select Series",
        showDismissButton: Bool = true,
        selectedSeries: Binding<Series?>? = nil
    ) {
        self.title = title
        self.showDismissButton = showDismissButton
        self._selectedSeries = selectedSeries ?? Binding.constant(nil)
        self.searchText = searchText
    }
    
    // MARK: - Body
    
    var body: some View {
        List {
            if searchResults.isEmpty {
                NavigationLink(value: "Add") {
                    Label("Add Custom", systemImage: "plus")
                }
            } else {
                Section {
                    ForEach(searchResults) { series in
                        SeriesRow(series: series)
                            .onTapGesture {
                                selectedSeries = series
                            }
                    }
                } footer: {
                    Text("Total: \(searchResults.count)")
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
        .searchable(text: $searchText)
        .toolbarVisibility(.visible, for: .navigationBar)
        .navigationDestination(for: String.self) { view in
            if view == "Add" {
                SeriesCreationView(series: $selectedSeries, name: searchText)
            }
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
