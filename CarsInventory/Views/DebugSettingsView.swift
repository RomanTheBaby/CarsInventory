//
//  DebugSettingsView.swift
//  CarsInventory
//
//  Created by Roman on 2025-05-09.
//

import OSLog
import SwiftUI
import TipKit

struct DebugSettingsView: View {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? String(describing: Self.self),
        category: String(describing: Self.self)
    )
    
    var body: some View {
        List {
            Button("Show all Tips for testing") {
                Tips.showAllTipsForTesting()
            }
        }
        .navigationTitle("Debug Settings")
    }
}

#Preview {
    NavigationStack {
        DebugSettingsView()
    }
}
