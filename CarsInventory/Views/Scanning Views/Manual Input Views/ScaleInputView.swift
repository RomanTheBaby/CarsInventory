//
//  ScaleInputView.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-18.
//

import SwiftUI

struct ScaleInputView: View {
    
    @Binding var selection: InventoryCar.Scale?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List(InventoryCar.Scale.allCases, id: \.rawValue) { scale in
            Text(scale.displayName)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    selection = scale
                    dismiss()
                }
        }
        .navigationTitle("Chose scale")
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
    @Previewable @State var scale: InventoryCar.Scale?
    NavigationStack {
        ScaleInputView(selection: $scale)
    }
}
