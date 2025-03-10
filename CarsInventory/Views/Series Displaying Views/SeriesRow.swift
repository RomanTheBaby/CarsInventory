//
//  SeriesRow.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-13.
//

import SwiftUI

struct SeriesRow: View {
    var series: Series
    
    var subtitle: String {
        var texts: [String] = []
        
        switch series.classification {
        case .premium, .silver:
            texts.append(series.classification.displayName)
        case .regular:
            break
        }
        
        texts.append("Cars: \(series.cars.count)")
        
        return texts.joined(separator: ", ")
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
}

#Preview {
    List(CarsInventoryAppPreviewData.previewSeries) { series in
        SeriesRow(series: series)
    }
}
