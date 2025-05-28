//
//  ModelInputView.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-16.
//

import SwiftUI

struct ModelInputView: View {
    
    // MARK: - Properties
    
    var brand: CarBrand? = nil
    @Binding var input: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelsSuggestionProvider)
    private var modelsSuggestionProvider: ModelsSuggestionProvider
    
    private var modelSuggestions: [String] {
        guard let brand else {
            return []
        }
        return modelsSuggestionProvider.suggestions(for: brand, query: input)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Spacer()
            TextField("Enter make...", text: $input, axis: .vertical)
                .font(.title2)
                .fontWeight(.medium)
                .submitLabel(.done)
                .autocorrectionDisabled()
                .onSubmit {
                    dismiss()
                }
            if modelSuggestions.isEmpty {
                Spacer()
            } else {
                VStack {
                    ForEach(modelSuggestions.prefix(5), id: \.self) { suggestion in
                        Button {
                            input = suggestion
                        } label: {
                            Text(.init("\(suggestion.replacingOccurrences(of: input, with: "**\(input)**"))"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8)
                                .font(.title2)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    input = ""
                    dismiss()
                } label: {
                    Text("Cancel")
                        .fontWeight(.bold)
                        .fontWeight(.medium)
                }
                
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .fontWeight(.bold)
                        .fontWeight(.medium)
                }
                
            }
        }
    }
}

// MARK: - Previews

#Preview {
    @Previewable @State var input: String = ""
    NavigationStack {
        ModelInputView(input: $input)
    }
}

#Preview("With brand") {
    @Previewable @State var input: String = ""
    NavigationStack {
        ModelInputView(brand: CarsInventoryAppPreviewData.previewCarBrands[4], input: $input)
    }
}
