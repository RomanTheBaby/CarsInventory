//
//  SeriesCarsView.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-13.
//

import SwiftUI

struct SeriesCarsView: View {
    var series: Series

    var body: some View {
        InventoryCarsListView(series: series)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SeriesCreationView(series: series)
                    } label: {
                        Text("Edit Series")
                    }
                }
            }
    }
}

// MARK: - Previews

#Preview("With Data") {
    NavigationStack {
        SeriesCarsView(series: CarsInventoryAppContainerSampleData.previewSeries[3])
            .modelContainer(CarsInventoryAppContainerSampleData.container)
    }
}

#Preview("No Data") {
    NavigationStack {
        SeriesCarsView(series: CarsInventoryAppContainerSampleData.previewSeries[3])
    }
}

#Preview("From Settings") {
    NavigationStack {
        SeriesListView()
    }
    .modelContainer(CarsInventoryAppContainerSampleData.container)
}
