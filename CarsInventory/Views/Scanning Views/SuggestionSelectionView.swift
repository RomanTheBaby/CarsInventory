//
//  SuggestionSelectionView.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-18.
//

import SwiftUI


// MARK: - FooterSelectionItem

protocol FooterSelectionItem: Equatable {
    var comparingId: String { get }
    var displayName: String { get }
}

// MARK: - SuggestionSelectionView

struct SuggestionSelectionView<Item: FooterSelectionItem & Equatable>: View {
    // MARK: - Properties
    
    var title: String
    var items: [Item]
    var titleLabelWidth: CGFloat?
    
    @Binding var selectedItem: Item?
    
    var manualInputActionHandler: (() -> Void)
    var selectionStatusChangeHandler: ((_ isSelected: Bool, _ item: Item) -> Void)? = nil
    
    private var sortedItems: [Item] {
        items.sorted(by: { lhs, rhs in
            lhs.displayName < rhs.displayName
        })
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            Text(title)
                .frame(minWidth: titleLabelWidth, alignment: .leading)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(sortedItems, id: \.comparingId) { item in
                        SuggestionButton(displayName: item.displayName, subtitle: item.subtitle, isSelected: selectedItem == item) {
                            if selectedItem == item {
                                selectedItem = nil
                            } else {
                                selectedItem = item
                            }
                            selectionStatusChangeHandler?(selectedItem == item, item)
                        }
                    }
                    
                    manuInputView
                }
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    var manuInputView: some View {
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

// MARK: - SuggestionButton

private struct SuggestionButton: View {
    var displayName: String
    var subtitle: String?
    
    var isSelected: Bool
    
    var action: (() -> Void)
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                Text(displayName)
                    .foregroundStyle(isSelected ? .white : Color.primary)
                    .multilineTextAlignment(.center)
                if let subtitle {
                    Text(subtitle)
                        .foregroundStyle(Color.secondary)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
            }
            .frame(minWidth: 50)
            .padding(8)
            .background(isSelected ? .blue : Color(uiColor: .lightGray).opacity(0.6))
            .cornerRadius(8)
        }
    }
}

// MARK: - Preview

#Preview {
    ScanningView()
        .modelContainer(CarsInventoryAppPreviewData.container)
}

// MARK: - FooterSelectionItem

private extension FooterSelectionItem {
    var subtitle: String? {
        guard let series = self as? Series else {
            return nil
        }
        
        var texts: [String] = []
        texts.reserveCapacity(2)
        
        switch series.classification {
        case .premium, .silver:
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

extension Series: FooterSelectionItem {
    var comparingId: String { id }
}

// MARK: CarBrand + FooterSelectionItem

extension CarBrand: FooterSelectionItem {
    var comparingId: String { "\(id)" }
}

// MARK: Franchise + FooterSelectionItem

extension Franchise: FooterSelectionItem {
    var comparingId: String { id }
}

// MARK: SeriesEntryNumber + FooterSelectionItem

extension SeriesEntryNumber: FooterSelectionItem {
    var comparingId: String {
        displayName
    }
    
    var displayName: String {
        "\(current)/\(total)"
    }
}

// MARK: String + FooterSelectionItem

extension String: FooterSelectionItem {
    var comparingId: String {
        self
    }
    
    var displayName: String {
        self
    }
}

// MARK: Int + FooterSelectionItem

extension Int: FooterSelectionItem {
    var comparingId: String {
        "\(self)"
    }
    
    var displayName: String {
        "\(self)"
    }
}

// MARK: Series + ColorOption

extension ColorOption: FooterSelectionItem {
    var comparingId: String {
        id
    }
}

// MARK: InventoryCar.Scale + FooterSelectionItem

extension InventoryCar.Scale: FooterSelectionItem {
    var comparingId: String {
        "\(rawValue)"
    }
}
