//
//  File.swift
//  Haptics
//
//  Created by Sjmarf on 2025-05-28.
//

import SwiftUI

private struct HapticConfigurationViewModifier: ViewModifier {
    @Environment(\.scenePhase) var scenePhase
        
    func body(content: Content) -> some View {
        content
            .environment(HapticManager.mainInternal)
            .onChange(of: scenePhase, initial: false) {
                if scenePhase == .active {
                    // When the app moves into the background, the haptic engine stops.
                    // This ensures the engine is started before a haptic is played to avoid a short lag while the engine starts
                    HapticManager.mainInternal.startEngine()
                }
            }
    }
}

public extension View {
    func hapticConfiguration(
        maximumHapticTier: HapticTier?,
        errorHandler: @escaping (HapticError) -> Void
    ) -> some View {
        HapticManager.mainInternal.errorHandler = errorHandler
        HapticManager.mainInternal.maximumHapticTier = maximumHapticTier
        
        return modifier(HapticConfigurationViewModifier())
    }
}
