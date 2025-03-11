//
//  EnvironmentKeys.swift
//  CarsInventory
//
//  Created by Roman on 2025-03-10.
//

import SwiftUI

// MARK: - ModelsSuggestionProvider

private struct ModelsSuggestionProviderKey: EnvironmentKey {
  static let defaultValue = ModelsSuggestionProvider()
}

extension EnvironmentValues {
  var modelsSuggestionProvider: ModelsSuggestionProvider {
    get { self[ModelsSuggestionProviderKey.self] }
    set { self[ModelsSuggestionProviderKey.self] = newValue }
  }
}
