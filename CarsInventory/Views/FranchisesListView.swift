//
//  FranchiseListView.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-22.
//

import SwiftUI
import SwiftData

struct FranchiseListView: View {
    
    @Query(sort: \Franchise.name)
    private var franchises: [Franchise]
    @State private var searchText: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    private var filteredFranchises: [Franchise] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return franchises
        }
        
        return franchises.filter {
            $0.name.lowercased().contains(query)
        }
    }
    
    var body: some View {
        Group {
            if filteredFranchises.isEmpty {
                Text("No franchises found")
                    .multilineTextAlignment(.center)
            } else {
                List {
                    ForEach(filteredFranchises) { franchise in
                        NavigationLink {
                            InventoryCarsListView(franchise: franchise)
                        } label: {
                            Text(franchise.displayName)
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Franchise")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    FranchiseCreationView()
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .searchable(text: $searchText)
    }
}

#Preview {
    NavigationStack {
        FranchiseListView()
    }
    .modelContainer(CarsInventoryAppPreviewData.container)
}
