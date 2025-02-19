//
//  CarSeriesNumberInputView.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-16.
//

import SwiftUI

struct CarSeriesNumberInputView: View {
    // MARK: - Properties
    
    @Binding var output: SeriesEntryNumber?

    @State private var currentCarNumber: Int = 1
    @State private var totalCarsCount: Int = 5
    
    @Environment(\.dismiss) private var dismiss
    
    init(output: Binding<SeriesEntryNumber?>) {
        self._output = output
        self.currentCarNumber = output.wrappedValue?.current ?? 1
        self.totalCarsCount = output.wrappedValue?.total ?? 5
    }

    // MARK: - Body
    
    var body: some View {
        VStack {
            Text("Enter car number in series")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.horizontal, .top])
            Spacer()
            HStack {
                PickerView(value: $currentCarNumber, minValue: 1)
                Text("out of")
                PickerView(value: $totalCarsCount, minValue: currentCarNumber)
            }
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .fontWeight(.bold)
                }

            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    output = SeriesEntryNumber(current: currentCarNumber, total: totalCarsCount)
                    dismiss()
                } label: {
                    Text("Done")
                        .fontWeight(.bold)
                }

            }
        }
        .onChange(of: currentCarNumber) { _, newValue in
            if newValue > totalCarsCount {
                totalCarsCount = newValue
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var output: SeriesEntryNumber? = nil
    NavigationStack {
        CarSeriesNumberInputView(output: $output)
    }
}
