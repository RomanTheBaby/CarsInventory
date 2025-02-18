//
//  YearPickerView.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-14.
//

import SwiftUI

struct YearPickerView<Content: View>: View {
    // MARK: - Propertie
    
    private var options: [Int]
    @Binding private var selection: Int
    private var label: Content
    
    // MARK: - Init
    
    init(
        options: [Int],
        selection: Binding<Int>,
        @ViewBuilder label: () -> Content
    ) {
        self.options = options
        self._selection = selection
        self.label = label()
    }
    
    init(
        minYear: Int,
        maxYear: Int = Calendar.current.component(.year, from: Date()),
        reverseOrder: Bool = false,
        selection: Binding<Int>,
        @ViewBuilder label: () -> Content
    ) {
        let currentYear = Calendar.current.component(.year, from: Date())
        var yearsRange = Array((minYear...currentYear))
        yearsRange.append(0)
        
        self.options = reverseOrder ? yearsRange.reversed() : yearsRange
        self._selection = selection
        self.label = label()
    }
    
    // MARK: - Body
    
    var body: some View {
        EmptyView()
        
        Picker(selection: $selection) {
            ForEach(options, id: \.self) { year in
                Text(year == 0 ? "Unknown" : String(year))
            }
        } label: {
            label
        }
    }
}

// MARK: - Previews

#Preview("With min and max values") {
    @Previewable @State var selection: Int = 2025
    YearPickerView(minYear: 1968, selection: $selection) {
        Text("Series Year")
        Text("Optional")
            .font(.footnote)
    }
}

#Preview("With options") {
    @Previewable @State var selection: Int = 2025
    YearPickerView(options: [0, 1, 2, 3, 2025], selection: $selection) {
        Text("Series Year")
        Text("Optional")
            .font(.footnote)
    }
}
