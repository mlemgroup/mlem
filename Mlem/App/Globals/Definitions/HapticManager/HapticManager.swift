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
    @Setting(\.hapticLevel) var hapticLevel
    @Setting(\.developerMode) var developerMode
    
    // generators/engines
    let rigidImpactGenerator: UIImpactFeedbackGenerator = .init(style: .rigid)
    let notificationGenerator: UINotificationFeedbackGenerator = .init()
    var hapticEngine: CHHapticEngine?

    // singleton to use in app
    static let main: HapticManager = .init()
    
    var players: [Haptic: CHHapticPatternPlayer] = .init()
    
    init() {
        // create and start the engine if this device supports haptics
        print("Initialized haptic engine")
        self.hapticEngine = initEngine()
        
        // load all the haptic files into players to avoid lag on first play caused by slow disk read
        loadPlayers()
        
        // if the engine stops, tell us why
        hapticEngine?.stoppedHandler = { reason in
            print("The engine stopped: \(reason)")
        }
        
        // if the engine fails, attempt to restart
        hapticEngine?.resetHandler = { [weak self] in
            print("The engine reset")
            self?.handleFailure()
        }
    }
    
    func startEngine() {
        if let engine = hapticEngine {
            do {
                try engine.start()
            } catch {
                // silently log error, re-create the engine, and retry
                handleError(error, silent: !developerMode)
                hapticEngine = initEngine()
                loadPlayers()
            }
        }
    }
    
    /// Plays a haptic if the given priority is equal to or lower than the current haptic level
    func play(haptic: Haptic, priority: HapticPriority) {
        assert(priority != .sentinel, "Cannot use .sentinel as a haptic priority")
        
        Task(priority: .userInitiated) {
            if priority <= hapticLevel, hapticEngine != nil {
                do {
                    guard let player = players[haptic] else { throw HapticError.noPlayer(haptic) }
                    try player.start(atTime: .zero)
                } catch {
                    handleError(error, silent: true)
                    handleFailure(with: haptic, error: error as? HapticError)
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
    
    /// If this device supports haptics, creates and returns a CHHaptic engine; otherwise returns nil
    private func initEngine() -> CHHapticEngine? {
        if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
            do {
                let ret = try CHHapticEngine(audioSession: AVAudioSession.sharedInstance())
                try ret.start()
                return ret
            } catch {
                handleError(error, silent: !developerMode)
            }
        }
        return nil
    }
    
    /// Restarts the engine if it is present, creates it if not, starts the engine, and plays the given haptic
    private func handleFailure(with haptic: Haptic? = nil, error: HapticError? = nil) {
        if hapticEngine == nil {
            hapticEngine = initEngine()
        }
        
        if let error, case let .noPlayer(failedHaptic) = error {
            assertionFailure("No player for \(failedHaptic)")
            loadPlayers()
        }
        
        if hapticEngine != nil {
            startEngine()
            
            // attempt to play the pattern that failed, but don't do anything on failure here
            if let haptic {
                do {
                    guard let player = players[haptic] else {
                        assertionFailure("No player for \(haptic) in failure handler")
                        throw HapticError.noPlayer(haptic)
                    }
                    try player.start(atTime: .zero)
                } catch {
                    handleError(error, silent: true)
                }
            }
        }
    }
    
    private func loadPlayers() {
        // load all the haptic files into players to avoid lag on first play caused by slow disk read
        Haptic.allCases.forEach { haptic in
            do {
                guard let path = Bundle.main.path(forResource: haptic.rawValue, ofType: "ahap") else {
                    assertionFailure("No haptic file found for \(haptic.rawValue)")
                    return
                }
                let file = URL(filePath: path)
                players[haptic] = try hapticEngine?.makePlayer(with: .init(contentsOf: file))
            } catch {
                assertionFailure("Failed to initialize haptic player")
                handleError(error, silent: true)
            }
        }
    }
}

enum HapticError: Error, CustomStringConvertible {
    case noPlayer(Haptic)
    
    public var description: String {
        switch self {
        case let .noPlayer(haptic):
            "No player available for \(haptic.rawValue)"
        }
    }
}
