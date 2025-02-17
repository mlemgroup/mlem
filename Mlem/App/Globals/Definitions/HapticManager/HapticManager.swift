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
        Haptic.allCases.forEach { haptic in
            do {
                guard let file = getFile(for: haptic) else { return }
                players[haptic] = try hapticEngine?.makePlayer(with: .init(contentsOf: file))
            } catch {
                assertionFailure("Failed to initialize haptic player")
                handleError(error, silent: true)
            }
        }
        
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
    
    func startEngine() {
        if let hapticEngine {
            do {
                try hapticEngine.start()
            } catch {
                handleError(error)
            }
        }
    }
    
    /// Plays a haptic if the given priority is equal to or lower than the current haptic level
    func play(haptic: Haptic, priority: HapticPriority) {
        assert(priority != .sentinel, "Cannot use .sentinel as a haptic priority")
        
        Task(priority: .userInitiated) {
            if priority <= hapticLevel, let hapticEngine {
                do {
                    guard let player = players[haptic] else { throw HapticError.noPlayer(haptic) }
                    try player.start(atTime: .zero)
                } catch {
                    // on failure, restart the engine and play the haptic from file
                    handleError(error, silent: true)
                    handleEngineFailure(with: haptic)
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
                handleError(error, silent: true)
            }
        }
        return nil
    }
    
    /// Restarts the engine if it is present, creates it if not, starts the engine, and plays the given haptic from file
    private func handleEngineFailure(with haptic: Haptic? = nil) {
        if hapticEngine == nil {
            hapticEngine = initEngine()
        }
        
        if let hapticEngine {
            startEngine()
            
            // attempt to play the pattern that failed, but don't do anything on failure here
            if let haptic, let file = getFile(for: haptic) {
                do {
                    try hapticEngine.playPattern(from: file)
                } catch {
                    handleError(error, silent: true)
                }
            }
        }
    }
    
    private func getFile(for haptic: Haptic) -> URL? {
        guard let path = Bundle.main.path(forResource: haptic.rawValue, ofType: "ahap") else {
            assertionFailure("No haptic file found for \(haptic.rawValue)")
            return nil
        }
    
        return URL(filePath: path)
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
