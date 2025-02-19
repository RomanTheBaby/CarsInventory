//
//  ModelInputView.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-16.
//

import SwiftUI

struct ModelInputView: View {
    
    // MARK: - Properties
    
    @Binding var input: String
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        TextField("Enter make...", text: $input, axis: .vertical)
            .font(.title2)
            .fontWeight(.medium)
            .padding(.leading)
            .submitLabel(.done)
            .autocorrectionDisabled()
            .onSubmit {
                dismiss()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        input = ""
                        dismiss()
                    } label: {
                        Text("Done")
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
