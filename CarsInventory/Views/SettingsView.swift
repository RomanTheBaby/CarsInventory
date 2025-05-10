//
//  SettingsView.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-12.
//

import OSLog
import SwiftUI

struct SettingsView: View {
    // MARK: - Properties
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? String(describing: Self.self),
        category: String(describing: Self.self)
    )
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        SeriesListView(showDismissButton: false)
                    } label: {
                        Text("All Series")
                    }
                    
                    NavigationLink {
                        FranchiseListView()
                    } label: {
                        Text("All Franchises")
                    }
                }
                
                #if DEBUG
                Section {
                    NavigationLink {
                        DebugSettingsView()
                    } label: {
                        Text("Debug Settings")
                    }
                }
                #endif
                
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
        .modelContainer(CarsInventoryAppPreviewData.container)
}
