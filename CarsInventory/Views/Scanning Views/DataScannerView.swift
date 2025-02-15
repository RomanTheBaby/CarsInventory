//
//  ScanningView.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-04.
//

import SwiftUI
import VisionKit
import SwiftData
import Combine

@MainActor
struct DataScannerView: UIViewControllerRepresentable {
    // MARK: - Properties

    @ObservedObject var viewModel: ScanningViewModel
    @Environment(\.modelContext) private var modelContext

    private var cancellables = Set<AnyCancellable>()
    
    private var scannerAvailable: Bool {
        DataScannerViewController.isSupported
            && DataScannerViewController.isAvailable
    }
    
    private var scannerViewController: DataScannerViewController = DataScannerViewController(
        recognizedDataTypes: [.text(languages: ["en-US"])],
        qualityLevel: .accurate,
        recognizesMultipleItems: true,
        isHighFrameRateTrackingEnabled: false,
        isHighlightingEnabled: true
    )
    
    // MARK: - Init
    
    init(viewModel: ScanningViewModel) {
        self.viewModel = viewModel
        
        viewModel.$isScanning.sink { [self] isScanning in
            if isScanning {
                do {
                    try scannerViewController.startScanning()
                } catch {
                    assertionFailure("Please fix. Failed to start scan with error: \(error)")
                }
            } else {
                scannerViewController.stopScanning()
            }
        }.store(in: &cancellables)
    }

    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    // MARK: - Coordinator

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: DataScannerView
        let processor: ScannerDataProcessor
        
        init(_ parent: DataScannerView) {
            self.parent = parent
            self.processor = ScannerDataProcessor(modelContext: parent.modelContext)
        }
        
        // MARK: - DataScannerViewControllerDelegate

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
//            print(">>>\(#function):\(#line)", allItems)
//            print(">>>Added")
            processItems(items: allItems)
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
//            print(">>>\(#function):\(#line)", allItems)
//            print(">>>Remove")
//            processItems(items: allItems)
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            print(">>>Update")
//            print(">>>\(#function):\(#line)", allItems)
            processItems(items: allItems)
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            print(">>>\(#function):\(#line)", item)
        }

        private func processItems(items: [RecognizedItem]) {
            guard let suggestion = processor.suggestions(from: items) else {
                return
            }

            parent.viewModel.update(from: suggestion)
        }
    }
}

#Preview {
    DataScannerView(viewModel: ScanningViewModel())
}
