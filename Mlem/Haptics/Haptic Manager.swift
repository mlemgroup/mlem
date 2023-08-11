//
//  Haptic Manager.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-17.
//

import Foundation
import SwiftUI
import CoreHaptics

class HapticManager {
    
    // MARK: Members and init
    
    @AppStorage("hapticLevel") var hapticLevel: HapticLevel = .all
    
    // generators/engines
    let rigidImpactGenerator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    let notificationGenerator: UINotificationFeedbackGenerator = UINotificationFeedbackGenerator()
    var hapticEngine: CHHapticEngine?
    
    // singleton to use in app
    static let shared = HapticManager()
    
    init() {
        // create and start the engine if this device supports haptics
        print("Initialized haptic engine")
        hapticEngine = initEngine()
        
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
    
    /**
     If this device supports haptics, creates and returns a CHHaptic engine; otherwise returns nil
     */
    @discardableResult func initEngine() -> CHHapticEngine? {
        if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
            do {
                let ret = try CHHapticEngine()
                try ret.start()
                return ret
            } catch {
                // TODO: feed to error handler once we have swift-repositories
                print("There was an error creating the engine: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    /**
     Restarts the engine if it is present, creates it if not. Can be passed a pattern to play on start.
     */
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
    
    /**
     Plays a haptic if the given priority is equal to or lower than the current haptic level
     */
    func play(haptic: Haptic, priority: HapticLevel) {
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
            print("no engine")
        }
    }
}
