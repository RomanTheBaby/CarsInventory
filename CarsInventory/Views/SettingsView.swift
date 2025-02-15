//
//  SettingsView.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-12.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    SeriesListView(showDismissButton: false)
                } label: {
                    Text("All Series")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(CarsInventoryAppContainerSampleData.container)
}
