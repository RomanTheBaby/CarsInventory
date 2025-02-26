//
//  SuggestionSelectionView.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-18.
//

import SwiftUI


// MARK: - FooterSelectionItem

protocol FooterSelectionItem: Equatable {
    var id: String { get }
    var displayName: String { get }
}

// MARK: - SuggestionSelectionView

struct SuggestionSelectionView<Item: FooterSelectionItem & Equatable>: View {
    var title: String
    var items: [Item]
    var titleLabelWidth: CGFloat?
    
    @Binding var selectedItem: Item?
    
    var manualInputActionHandler: (() -> Void)
    
    private var sortedItems: [Item] {
        items.sorted(by: { lhs, rhs in
            lhs.displayName < rhs.displayName
        })
    }
    
    var body: some View {
        HStack {
            Text(title)
                .frame(width: titleLabelWidth, alignment: .leading)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(sortedItems, id: \.id) { item in
                        Button {
                            if selectedItem == item {
                                selectedItem = nil
                            } else {
                                selectedItem = item
                            }
                        } label: {
                            VStack {
                                Text(item.displayName)
                                    .foregroundStyle(selectedItem == item ? .white : Color.primary)
                                    .multilineTextAlignment(.center)
                                if let subtitle = item.subtitle {
                                    Text(subtitle)
                                        .foregroundStyle(Color.secondary)
                                        .font(.footnote)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                            }
                            .frame(minWidth: 50)
                            .padding(8)
                            .background(selectedItem == item ? .blue : Color(uiColor: .lightGray).opacity(0.6))
                            .cornerRadius(8)
                        }
                    }
                    
                    Button {
                        manualInputActionHandler()
                    } label: {
                        HStack(spacing: 0) {
                            Text("Enter manually | ")
                                .foregroundStyle(Color.primary)
                            
                            Image(systemName: "plus")
                                .foregroundStyle(Color.primary)
                        }
                        .frame(minWidth: 50)
                        .padding(8)
                        .background(Color(uiColor: .lightGray).opacity(0.6))
                        .cornerRadius(8)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview

#Preview {
    ScanningView()
        .modelContainer(CarsInventoryAppPreviewData.container)
}

private extension FooterSelectionItem {
    var subtitle: String? {
        guard let series = self as? Series else {
            return nil
        }
        
        var texts: [String] = []
        texts.reserveCapacity(2)
        
        switch series.classification {
        case .premium:
            texts.append(series.classification.displayName)
        case .regular:
            break
        }
        
        if let year = series.year {
            texts.append(String(year))
        }
        
        let subtitle = texts.joined(separator: ", ")
        return subtitle.isEmpty ? nil : subtitle
    }
}

// MARK: Series + FooterSelectionItem

extension Series: FooterSelectionItem {}

// MARK: CarBrand + FooterSelectionItem

extension CarBrand: FooterSelectionItem {}

// MARK: Franchise + FooterSelectionItem

extension Franchise: FooterSelectionItem {}

// MARK: SeriesEntryNumber + FooterSelectionItem

extension SeriesEntryNumber: FooterSelectionItem {
    var id: String {
        displayName
    }
    
    var displayName: String {
        "\(current)/\(total)"
    }
}

// MARK: String + FooterSelectionItem

extension String: FooterSelectionItem {
    var id: String {
        self
    }
    
    var displayName: String {
        self
    }
}

// MARK: Int + FooterSelectionItem

extension Int: FooterSelectionItem {
    var id: String {
        "\(self)"
    }
    
    var displayName: String {
        "\(self)"
    }
}

// MARK: Series + ColorOption

extension ColorOption: FooterSelectionItem {}

// MARK: InventoryCar.Scale + FooterSelectionItem

extension InventoryCar.Scale: FooterSelectionItem {
    var id: String {
        "\(rawValue)"
    }
}
