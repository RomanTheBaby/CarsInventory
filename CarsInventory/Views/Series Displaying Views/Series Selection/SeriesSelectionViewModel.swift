//
//  SeriesSelectionViewModel.swift
//  CarsInventory
//
//  Created by Roman on 2025-05-11.
//

import Combine
import Foundation

class SeriesSelectionViewModel: ObservableObject {
    @Published var searchText: String
    @Published private(set) var debouncedSearchText = ""
    
    @Published private(set) var seriesList: [Series] = []
    
    init(searchText: String = "") {
        self.searchText = searchText
        self.debouncedSearchText = searchText
        
        $searchText
            .debounce(for: .seconds(0.33), scheduler: RunLoop.main)
            .assign(to: &$debouncedSearchText)
    }
    
    func updateDisplayedItems(for query: String, series: [Series]) {
        let filteredSeries = searchText.isEmpty ? series : series.filter { series in
            series.allNames.contains(where: { $0.lowercased().contains(searchText.lowercased()) })
        }
        
        seriesList = filteredSeries
            .sorted { lhs, rhs in
                if lhs.isUnknown || rhs.isUnknown {
                    return lhs.isUnknown
                }
                
                return lhs.displayName < rhs.displayName
            }
    }
}
