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
                Section {
                    NavigationLink {
                        SeriesListView(showDismissButton: false)
                    } label: {
                        Text("All Series")
                    }
                }
                
                Section {
                    Link(
                        "Leave a review",
                        destination: URL(string: "https://apps.apple.com/us/app/drillbuddy/id6473848506")!
                    )
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
