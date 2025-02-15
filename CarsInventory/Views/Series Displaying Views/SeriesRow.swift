//
//  SeriesRow.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-13.
//

import SwiftUI

struct SeriesRow: View {
    var series: Series
    
    var body: some View {
        HStack {
            VStack {
                Text(series.fullName)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Cars: \(series.cars.count)")
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
    List(CarsInventoryAppContainerSampleData.previewSeries) { series in
        SeriesRow(series: series)
    }
}
