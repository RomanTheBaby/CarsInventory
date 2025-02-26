//
//  Franchise.swift
//  CarsInventory
//
//  Created by Roman on 2025-02-18.
//

import Foundation
import SwiftData

@Model
class Franchise: Identifiable, Hashable {
    @Attribute(.unique)
    var id: String
    var name: String
    
    @Transient
    var displayName: String {
        name
    }
    
    var series: [Series] = []
    
    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
    }
}
