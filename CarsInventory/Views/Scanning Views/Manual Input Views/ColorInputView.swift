//
//  ColorInputView.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-18.
//

import SwiftUI

struct ColorInputView: View {
    
    @Binding var selection: ColorOption?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List(ColorOption.allCases, id: \.rawValue) { color in
            Text(color.displayName)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    selection = color
                    dismiss()
                }
        }
        .navigationTitle("Chose color")
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
    }
}

#Preview {
    @Previewable @State var selection: ColorOption? = nil
    NavigationStack {
        ColorInputView(selection: $selection)
    }
}
