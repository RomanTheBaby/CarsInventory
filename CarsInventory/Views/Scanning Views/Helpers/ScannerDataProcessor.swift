//
//  ScannerDataProcessor.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-04.
//

import Foundation
import OSLog
import RegexBuilder
import SwiftData
import SwiftUI
import VisionKit

// Possible formats:
// BMW 320 Group 5
// 2024 Nissan Z GT4
// "REXY" Porsche 911 GT3 R (992)
// Porsche 911 Carrera RS 2.7
// '73 JEEP J10
class ScannerDataProcessor {
    private lazy var logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? String(describing: Self.self),
        category: String(describing: Self.self)
    )
    
    private let ignoredWords: Set<String> = ["mattel", "hot wheels"]
    
    // MARK: - Properties
    
    private let seriesList: [Series]
    private let modelContext: ModelContext
    
    private lazy var seriesRegex = Regex {
        Capture {
            OneOrMore(.digit)
        }
        
        ChoiceOf {
            "/"
            ":"
        }
        
        Capture {
            OneOrMore(.digit)
        }
    }
    
    private lazy var carYearRegex = Regex {
        "'"
        
        Capture {
            OneOrMore(.digit)
        }
    }
    
    // MARK: - Init
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        do {
            let fetchDescriptor = FetchDescriptor<Series>()
            seriesList = try modelContext.fetch(fetchDescriptor)
        } catch {
            assertionFailure("PLEASE FIX. Failed to fetch series with error: \(error).")
            seriesList = []
        }
    }
    
    // This method assumes recognized item come from scanning one box of die cast
    func suggestions(from items: [RecognizedItem]) -> ScanningSuggestion? {
        let bannedSymbols = Set(["™", "®", "©"])
        let transcripts = items.compactMap { item -> String? in
            guard let transcript = item.textTranscript, ignoredWords.contains(transcript.lowercased()) == false else {
                return nil
            }
            let trimmedTranscript = transcript.filter { bannedSymbols.contains(String($0)) == false }
            return trimmedTranscript.isEmpty ? nil : trimmedTranscript
        }
        
        var brandSuggestions: Set<CarBrand> = []
        var modelSuggestions: Set<String> = []
        var yearSuggestions: Set<Int> = []
        
        transcripts.forEach { transcript  in
            let trimmedTranscript = transcript.filter { bannedSymbols.contains(String($0)) == false }
            CarBrand.allCases.forEach { brand in
                if trimmedTranscript.lowercased().contains(brand.displayName.lowercased()) {
                    brandSuggestions.insert(brand)
                    
                    let components = trimmedTranscript.lowercased()
                        .components(separatedBy: brand.displayName.lowercased())
                        .filter { $0.isEmpty == false }
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    
                    if let makeInformation = components.last, makeInformation.isEmpty == false {
                        modelSuggestions.insert(makeInformation.uppercased())
                        
                        if components.count >= 2, let yearString = components.first {
                            // If there are more than 2 components, then potentially the first one is year
                            if let yearSuggestion = Int(yearString) {
                                yearSuggestions.insert(yearSuggestion)
                            } else if let match = yearString.firstMatch(of: carYearRegex), let yearSuggestion = Int("19\(match.1)") {
                                yearSuggestions.insert(yearSuggestion)
                            }
                        }
                    }
                }
            }
        }

        let seriesSuggestions = transcripts.flatMap { transcript in
            let result = seriesList.filter { series in
                series.allNames.contains(where: {
//                    $0.lowercased() == trimmedTranscript.lowercased()
                        $0.lowercased() == transcript.lowercased()
//                        || $0.lowercased().contains(transcript.lowercased())
//                        || transcript.lowercased().contains($0.lowercased())
                })
            }
            logger.log(level: .info, "Series suggestion search for \(transcript) found \(result.count) match(es)")
            return result
        }

        // Getting series number suggestions
        let seriesNumberSuggestions = transcripts.compactMap { transcript -> SeriesEntryNumber? in
//            print(">>>SERIES TRANS: ", transcript)
//            guard let match = transcript.wholeMatch(of: #"^\d+[:/]\d+$"#),
//                  let firstMatch = match.first,
//                  let lastMatch = match.last,
//                  let current = Int(String(firstMatch)),
//                  let total = Int(String(lastMatch)) else {
//                return nil
//            }
            guard let match = transcript.wholeMatch(of: seriesRegex) else {
                return nil
            }
            
            let (_, currentEntryValue, totalEntriesValue) = match.output
//            print(">>>SERIES TRANS2: ", transcript, currentEntryValue, totalEntriesValue)
            guard let current = Int(currentEntryValue),
                  let total = Int(totalEntriesValue) else {
                return nil
            }
            
//            print(">>>SERIES TRANS2: ", transcript, current, total)
            
            return SeriesEntryNumber(current: current, total: total)
        }
        
        return ScanningSuggestion(
            brands: Array(brandSuggestions),
            models: Array(modelSuggestions),
            series: seriesSuggestions,
            seriesNumber: seriesNumberSuggestions,
            years: Array(yearSuggestions)
        )
    }
}

// MARK: - RecognizedItem Helpers

private extension RecognizedItem {
    var textTranscript: String? {
        switch self {
        case .text(let text):
            return text.transcript
        case .barcode:
            return nil
        @unknown default:
            assertionFailure("How did this happen")
            return nil
        }
    }
}
