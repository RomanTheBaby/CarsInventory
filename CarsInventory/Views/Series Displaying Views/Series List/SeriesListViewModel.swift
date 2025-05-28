//
//  SeriesListViewModel.swift
//  CarsInventory
//
//  Created by Roman on 2025-05-11.
//

import Combine
import Foundation
import SwiftData

class SeriesListViewModel: ObservableObject {
    enum RowItem: Identifiable {
        case unknownSeries
        case series(Series)
        
        var id: String {
            switch self {
            case .unknownSeries:
                return "Unknown"
            case .series(let series):
                return series.id + "_" + series.displayName
            }
        }
        
        var displayName: String {
            switch self {
            case .unknownSeries:
                return "Unknown"
            case .series(let series):
                return series.displayName
            }
        }
        
        var allNames: Set<String> {
            switch self {
            case .unknownSeries:
                return ["Unknown"]
            case .series(let series):
                return series.allNames
            }
        }
    }
    
    @Published var searchText: String
    @Published private(set) var debouncedSearchText = ""
    
    @Published private(set) var rowItems: [RowItem] = []

    init(searchText: String = "") {
        self.searchText = searchText
        self.debouncedSearchText = searchText
        
        $searchText
            .debounce(for: .seconds(0.33), scheduler: RunLoop.main)
            .assign(to: &$debouncedSearchText)
    }
    
    func updateRowItems(for query: String = "", series: [Series]) {
        rowItems = {
            let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if query.isEmpty {
                return [RowItem.unknownSeries] + series.map(RowItem.series(_:))
            }
            
            let rowItems = series.filter {
                $0.allNames.contains(where: { $0.lowercased().contains(trimmedQuery.lowercased())
                })
            }.map(RowItem.series(_:))
            
            if RowItem.unknownSeries.allNames.contains(query) {
                return [RowItem.unknownSeries] + rowItems
            }
            
            return rowItems
        }()
    }
    
}
