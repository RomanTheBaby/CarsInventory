//
//  PickerView.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-16.
//

import SwiftUI

struct PickerView: View {
    private enum Constancts {
        enum StepButton {
            static let size = CGSize(width: 18, height: 18)
        }
    }
    
    // MARK: - Properties
    
    @Binding var value: Int
    var step: Int = 1
    var minValue: Int = 0
    
    private var isAtMindValue: Bool {
        value <= minValue
    }

    // MARK: - Body
    
    var body: some View {
        HStack {
            Button {
                decrementStep()
            } label: {
                Image(systemName: "minus")
                    .frame(
                        width: Constancts.StepButton.size.width,
                        height: Constancts.StepButton.size.height
                    )
                    .foregroundColor(isAtMindValue ? .secondary : .primary)
            }
            .buttonStyle(.bordered)
            .disabled(isAtMindValue)
            
            TextFieldDynamicWidth(
                title: "Number",
                value: $value,
                formatter: NumberFormatter(),
                minWidth: 18
            )
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            
            Button {
                incrementStep()
            } label: {
                Image(systemName: "plus")
                    .frame(
                        width: Constancts.StepButton.size.width,
                        height: Constancts.StepButton.size.height
                    )
                    .foregroundColor(Color.primary)
            }
            .buttonStyle(.bordered)
        }
    }
    
    // MARK: - Private Methods
    
    private func incrementStep() {
        value += step
    }
    
    private func decrementStep() {
        value = max(value - step, minValue)
    }
}

// MARK: - Previews

#Preview {
    @Previewable @State var value: Int = 0
    PickerView(value: $value)
}

struct TextFieldDynamicWidth<Value>: View {
    let title: String
    @Binding var value: Value
    var formatter: Formatter
    var minWidth: CGFloat = 0
    
    @State private var textRect = CGRect()
    
    var body: some View {
        ZStack {
            Text("\(value)")
                .background(GlobalGeometryGetter(rect: $textRect))
                .layoutPriority(1)
                .opacity(0)
            HStack {
                TextField(
                    title,
                    value: $value,
                    formatter: formatter
                )
                .frame(width: max(minWidth, textRect.width))
            }
        }
    }
}

///
///  source: https://stackoverflow.com/a/56729880/3902590
///
private struct GlobalGeometryGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        return GeometryReader { geometry in
            self.makeView(geometry: geometry)
        }
    }

    func makeView(geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = geometry.frame(in: .global)
        }

        return Rectangle().fill(Color.clear)
    }
}
