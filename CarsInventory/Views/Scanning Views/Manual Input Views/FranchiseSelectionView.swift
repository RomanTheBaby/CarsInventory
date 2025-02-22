//
//  FranchiseSelectionView.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-21.
//

import SwiftUI
import SwiftData

struct FranchiseSelectionView: View {

    @Binding var selection: Franchise?
    
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
                        HStack {
                            Text(franchise.name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            if selection == franchise {
                                Image(systemName: "checkmark")
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selection = franchise
                            dismiss()
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Franchise")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .fontWeight(.bold)
                }
                
            }
        }
        .searchable(text: $searchText)
    }
}

#Preview {
    @Previewable @State var selection: Franchise?
    NavigationStack {
        FranchiseSelectionView(selection: $selection)
    }
    .modelContainer(CarsInventoryAppPreviewData.container)
}

#Preview("with selected franchise") {
    NavigationStack {
        FranchiseSelectionView(
            selection: Binding(
                get: {
                    CarsInventoryAppPreviewData.previewFranchises[0]
                }, set: { _ in
                    
                }
            )
        )
    }
    .modelContainer(CarsInventoryAppPreviewData.container)
}
