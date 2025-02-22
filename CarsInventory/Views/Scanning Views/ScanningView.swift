//
//  ScanningView.swift
//  CarsInventory
//
//  Created by Roman on 2025-01-06.
//

import SwiftUI
import AVFoundation

struct ScanningView: View {
    
    private enum Constancts {
        enum TochButton {
            static let size: CGSize = CGSize(width: 50, height: 50)
        }
    }
    
    // MARK: - Properties
    
    @StateObject var viewModel = ScanningViewModel()
    @State var isFlashlightOn = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: -16) {
            ZStack {
                DataScannerView(viewModel: viewModel)
                    .ignoresSafeArea(.all, edges: .top)
                torchButton
            }
            ScannerFooterView(viewModel: viewModel)
        }
    }
    
    private var torchButton: some View {
        Button {
            isFlashlightOn.toggle()
            setTorchIsOn(isFlashlightOn)
        } label: {
            Image(systemName: isFlashlightOn ? "flashlight.on.fill" : "flashlight.off.fill")
                .padding()
        }
        .frame(width: Constancts.TochButton.size.width, height: Constancts.TochButton.size.height)
        .foregroundColor(.white)
        .background(isFlashlightOn ? Color.white.opacity(0.5) : Color.black.opacity(0.5))
        .cornerRadius(Constancts.TochButton.size.width / 2)
        .position(
            x: Constancts.TochButton.size.width / 2 + 24,
            y: 24//Constancts.TochButton.size.height / 2 + 16
        )
    }
    
    // MARK: - Private Methods
    
    private func setTorchIsOn(_ isOn: Bool) {
        let device: AVCaptureDevice?
        
        if #available(iOS 17, *) {
            device = AVCaptureDevice.userPreferredCamera
        } else {
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: [
                    .builtInTripleCamera,
                    .builtInDualWideCamera,
                    .builtInUltraWideCamera,
                    .builtInWideAngleCamera,
                    .builtInTrueDepthCamera,
                ],
                mediaType: AVMediaType.video,
                position: .back
            ) // adapted from [https://www.appsloveworld.com/swift/100/46/avcapturesession-freezes-when-torch-is-turned-on] to fix freezing issue when activating torch
            device = deviceDiscoverySession.devices.first
        }
        
        guard let device, device.hasTorch && device.isTorchAvailable else {
            return
        }

        do {
            try device.lockForConfiguration()

            if isOn {
                try device.setTorchModeOn(level: 1.0)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            assertionFailure("Failed to set torch on with error: \(error)")
        }
    }
}

#Preview {
    ScanningView()
        .modelContainer(CarsInventoryAppPreviewData.container)
}
