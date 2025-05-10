//
//  SeriesRow.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-13.
//

import SwiftUI

struct SeriesRow: View, Equatable {
    let series: Series
    let subtitle: String
    
    init(series: Series) {
        self.series = series
        self.subtitle = {
            var texts: [String] = []
            
            switch series.classification {
            case .premium, .silver:
                texts.append(series.classification.displayName)
            case .regular:
                break
            }
            
            texts.append("Cars: \(series.cars.count)")
            
            return texts.joined(separator: ", ")
        }()
    }
    
    var body: some View {
        HStack {
            VStack {
                Text(series.displayName)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(subtitle)
                    .font(.caption)
                    .fontWeight(.light)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if let year = series.year {
                Text(String(year))
                    .font(.callout)
            }
        }
    }
    
    static func == (lhs: SeriesRow, rhs: SeriesRow) -> Bool {
        lhs.series.displayName == rhs.series.displayName
            && lhs.subtitle == rhs.subtitle
            && lhs.series.year == rhs.series.year
    }
}

#Preview {
    List(CarsInventoryAppPreviewData.previewSeries) { series in
        SeriesRow(series: series)
    }
}
