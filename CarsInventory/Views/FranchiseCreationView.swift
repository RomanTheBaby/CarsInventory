//
//  FranchiseCreationView.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-21.
//

import SwiftUI
import SwiftData

struct FranchiseCreationView: View {
    
    @State private var name: String = ""
    @State private var error: Error?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext: ModelContext
    
    var body: some View {
        Form {
            LabeledContent {
                TextField("Name", text: $name)
                    .multilineTextAlignment(.trailing)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
            } label: {
                Text("Name")
                Text("Required")
                    .font(.footnote)
            }
        }
        .errorAlert(error: $error)
        .navigationTitle("Add New Franchise")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .fontWeight(.medium)
                }
            }
            
            ToolbarItem(placement: .bottomBar) {
                Button {
                    do {
                        if let duplicateFranchise = try fetchFranchise(withName: name.trimmingCharacters(in: .whitespacesAndNewlines)) {
                            error = LocalizedErrorInfo(
                                errorDescription: "Franchise with the name \(duplicateFranchise.name) already exists.",
                                recoverySuggestion: "Please choose a different name"
                            )
                        } else {
                            let newFranchise = Franchise(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
                            modelContext.insert(newFranchise)
                            dismiss()
                        }
                    } catch {
                        self.error = error
                    }
                } label: {
                    Text("Create")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
    
    private func fetchFranchise(withName name: String) throws -> Franchise? {
        let predicate = #Predicate<Franchise> {
            $0.name == name
        }
        var fetchDescriptor = FetchDescriptor<Franchise>(predicate: predicate)
        fetchDescriptor.fetchLimit = 1
        return try modelContext.fetch(fetchDescriptor).first
    }
}

#Preview {
    NavigationStack {
        FranchiseCreationView()
    }
    .modelContainer(CarsInventoryAppPreviewData.container)
}
