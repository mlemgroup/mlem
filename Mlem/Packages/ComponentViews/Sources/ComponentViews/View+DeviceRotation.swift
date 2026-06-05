//
//  View+DeviceRotation.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-06-04.
//

// Taken directly from https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-device-rotation

import SwiftUI

private struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

public extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
