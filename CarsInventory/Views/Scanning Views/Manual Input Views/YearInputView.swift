//
//  YearInputView.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-18.
//

import SwiftUI

struct YearInputView: View {
    // MARK: - Properties
    
    @Binding var input: Int?
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        TextField("Enter Year", value: $input, formatter: NumberFormatter())
            .keyboardType(.numberPad)
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
