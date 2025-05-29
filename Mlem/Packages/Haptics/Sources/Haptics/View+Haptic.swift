//
//  File.swift
//  Haptics
//
//  Created by Sjmarf on 2025-05-28.
//

import SwiftUI

public extension View {
//    @Environment(\.scenePhase) var scenePhase
    
    func hapticConfiguration(
        maximumHapticLevel: HapticLevel?,
        errorHandler: @escaping (HapticError) -> Void
    ) -> some View {
        HapticManager.mainInternal.errorHandler = errorHandler
        HapticManager.mainInternal.maximumHapticLevel = maximumHapticLevel
        
        return environment(HapticManager.mainInternal)
//            .onChange(of: scenePhase, initial: false) {
//                if scenePhase == .active {
//                    // When the app moves into the background, the haptic engine stops.
//                    // This ensures the engine is started before a haptic is played to avoid a short lag while the engine starts
//                    HapticManager.main.startEngine()
//                }
//            }
    }
}
