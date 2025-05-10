//
//  StartScanningTip.swift
//  CarsInventory
//
//  Created by Roman on 2025-03-10.
//

import TipKit

struct ScanningControlsExpansionTip: Tip {
    var title: Text {
        Text("Need to add more info?")
    }
    
    var message: Text? {
        Text("Tap here or swipe up to reveal/hide additional inputs")
    }
    
    var image: Image? {
        Image(systemName: "rectangle.expand.vertical")
    }
    
    var options: [any TipOption] {
        [
            MaxDisplayCount(1),
        ]
    }
}

struct ScanningControlsTip: Tip {
    static let didUseControls: Event = Event(id: "didUseControls")

    var title: Text {
        Text("General Controls")
    }

    var message: Text? {
        Text("Use buttons below to add start scanning info from camera, add scanned items to your inventory, and clear already scanned suggestions. Suggestions will also clear once you've added something to your inventory.")
    }

    var image: Image? { nil }
    
    var rules: [Rule] {
        #Rule(Self.didUseControls) {
            $0.donations.count < 2
        }
    }
    
    var options: [any TipOption] {
        [
            MaxDisplayCount(1),
            MaxDisplayDuration(40.0),
        ]
    }
}
