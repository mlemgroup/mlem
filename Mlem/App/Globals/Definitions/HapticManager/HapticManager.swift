//
//  HapticManager.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-17.
//

import AVFAudio
import CoreHaptics
import Foundation
import SwiftUI

class HapticManager {
    // MARK: Members and init
    
    @Setting(\.hapticLevel) var hapticLevel
    
    // generators/engines
    let rigidImpactGenerator: UIImpactFeedbackGenerator = .init(style: .rigid)
    let notificationGenerator: UINotificationFeedbackGenerator = .init()
    var hapticEngine: CHHapticEngine?
    
    // singleton to use in app
    static let main: HapticManager = .init()
    
    init() {
        // create and start the engine if this device supports haptics
        print("Initialized haptic engine")
        self.hapticEngine = initEngine()
        
        // if the engine stops, tell us why
        hapticEngine?.stoppedHandler = { reason in
            print("The engine stopped: \(reason)")
        }
        
        // if the engine fails, attempt to restart
        hapticEngine?.resetHandler = { [weak self] in
            print("The engine reset")
            self?.handleEngineFailure()
        }
    }

    /// Starts the haptic engine, if present; call at app initialization to avoid lag on first haptic
    func preheat() {
        do {
            try hapticEngine?.start()
        } catch {
            handleError(error)
        }
    }
    
    /// If this device supports haptics, creates and returns a CHHaptic engine; otherwise returns nil
    func initEngine() -> CHHapticEngine? {
        if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
            do {
                let ret = try CHHapticEngine(audioSession: nil)
                try ret.start()
                return ret
            } catch {
                // TODO: feed to error handler once we have swift-repositories
                print("There was an error creating the engine: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    /// Restarts the engine if it is present, creates it if not. Can be passed a pattern to play on start.
    func handleEngineFailure(with file: URL? = nil) {
        if let hapticEngine {
            start(engine: hapticEngine)
            
            // attempt to play the pattern that failed, but don't do anything on failure here
            if let file {
                do {
                    try hapticEngine.playPattern(from: file)
                } catch {
                    print("Failed to play pattern: \(error.localizedDescription). Will not restart engine.")
                }
            }
        } else {
            hapticEngine = initEngine()
        }
    }
    
    func start(engine: CHHapticEngine) {
        do {
            try engine.start()
        } catch {
            print("Failed to start the engine: \(error)")
        }
    }
    
    /// Plays a haptic if the given priority is equal to or lower than the current haptic level
    func play(haptic: Haptic, priority: HapticPriority) {
        assert(priority != .sentinel, "Cannot use .sentinel as a haptic priority")
        
        Task(priority: .userInitiated) {
            if priority <= hapticLevel, let hapticEngine {
                guard let path = Bundle.main.path(forResource: haptic.rawValue, ofType: "ahap") else {
                    assertionFailure("Invalid haptic file: \(haptic.rawValue)")
                    return
                }
                
                let file = URL(filePath: path)
                do {
                    try hapticEngine.playPattern(from: file)
                } catch {
                    // worst-case scenario--tried to play and no engine!
                    print("Failed to play pattern: \(error.localizedDescription). Attempting to restart engine.")
                    handleEngineFailure(with: file)
                }
            } else {
                if priority > hapticLevel {
                    print("\(haptic.rawValue) not played (priority \(priority.intValue) > \(hapticLevel.intValue))")
                } else {
                    print("\(haptic.rawValue) not played (no engine)")
                }
            }
        }
    }
}
