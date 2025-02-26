//
//  ColorOption.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-14.
//

import Foundation

enum ColorOption: String, Hashable, CaseIterable, Codable, Identifiable {
    case amber
    case black
    case blue
    case charteuse
    case magenta
    case orange
    case gray
    case green
    case purple
    case red
    case teal
    case violet
    case vermillion
    case white
    case yellow
    case unspecified
    
    var id: String {
        rawValue
    }
    
    var displayName: String {
        rawValue.capitalized
    }
}
