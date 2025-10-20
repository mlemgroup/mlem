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
import os

@Observable
public class HapticManager {
    private static let logger = Logger(
        subsystem: Bundle.module.bundleIdentifier ?? "unknown",
        category: String(describing: HapticManager.self)
    )
    
    static let mainInternal: HapticManager = .init()
    
    @available(*, deprecated, message: "Access the HapticManager from the environment instead.")
    public static var main: HapticManager { mainInternal }
    
    // Config
    var errorHandler: (HapticError) -> Void = { HapticManager.logger.error("Haptic error: \($0.description)") }
    var maximumHapticTier: HapticTier?
    
    // generators/engines
    private let rigidImpactGenerator: UIImpactFeedbackGenerator = .init(style: .rigid)
    private let notificationGenerator: UINotificationFeedbackGenerator = .init()
    private var hapticEngine: CHHapticEngine?
    
    private var players: [Haptic: CHHapticPatternPlayer] = .init()
    
    private init() {
        // create and start the engine if this device supports haptics
        self.hapticEngine = initEngine()
        
        // load all the haptic files into players to avoid lag on first play caused by slow disk read
        loadPlayers()
        
        // if the engine stops, tell us why
        hapticEngine?.stoppedHandler = { reason in
            Self.logger.warning("The engine stopped: \(String(describing: reason))")
        }
        
        // if the engine fails, attempt to restart
        hapticEngine?.resetHandler = { [weak self] in
            Self.logger.warning("The engine reset")
            self?.handleFailure()
        }
        
        Self.logger.info("Initialized haptic engine")
    }
    
    func startEngine() {
        if let engine = hapticEngine {
            do {
                try engine.start()
            } catch {
                // silently log error, re-create the engine, and retry
                errorHandler(.failedToStartEngine(error))
                hapticEngine = initEngine()
                loadPlayers()
            }
        }
    }
    
    /// Plays a haptic if the given priority is equal to or lower than the current haptic level
    public func play(haptic: Haptic, tier: HapticTier) {
        Task(priority: .userInitiated) {
            if hapticEngine == nil {
                Self.logger.warning("\(haptic.rawValue) not played (no engine)")
                return
            }
            
            if tier.intValue <= (maximumHapticTier?.intValue ?? 0) {
                do {
                    guard let player = players[haptic] else { throw HapticError.noPlayer(haptic) }
                    try player.start(atTime: .zero)
                } catch {
                    errorHandler(.failedToStartPlayer(error))
                    handleFailure(with: haptic, error: error as? HapticError)
                }
            } else {
                Self.logger.debug("\(haptic.rawValue) not played (priority \(tier.intValue) > \(self.maximumHapticTier?.intValue ?? 0))")
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
                errorHandler(.failedToStartEngine(error))
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
                guard let player = players[haptic] else {
                    assertionFailure("No player for \(haptic) in failure handler")
                    errorHandler(.noPlayer(haptic))
                    return
                }
                do {
                    try player.start(atTime: .zero)
                } catch {
                    errorHandler(.failedToStartPlayer(error))
                }
            }
        }
    }
    
    private func loadPlayers() {
        // load all the haptic files into players to avoid lag on first play caused by slow disk read
        for haptic in Haptic.allCases {
            do {
                guard let path = Bundle.module.path(forResource: haptic.rawValue, ofType: "ahap") else {
                    assertionFailure("No haptic file found for \(haptic.rawValue)")
                    continue
                }
                let file = URL(filePath: path)
                players[haptic] = try hapticEngine?.makePlayer(with: .init(contentsOf: file))
            } catch {
                assertionFailure("Failed to initialize haptic player")
                errorHandler(.failedToMakePlayer(error))
            }
        }
    }
}
