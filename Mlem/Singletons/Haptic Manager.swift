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
    
    // generators/engines
    let rigidImpactGenerator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    let notificationGenerator: UINotificationFeedbackGenerator = UINotificationFeedbackGenerator()
    var hapticEngine: CHHapticEngine?
    
    // singleton to use in app
    static let shared = HapticManager()
    
    private init() {
        // create and start the engine if this device supports haptics
        hapticEngine = initEngine()
    }
    
    /**
     If this device supports haptics, creates and returns a CHHaptic engine; otherwise returns nil
     */
    func initEngine() -> CHHapticEngine? {
        if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
            do {
                let ret = try CHHapticEngine()
                try ret.start()
                return ret
            } catch {
                print("There was an error creating the engine: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    // MARK: - Informative
    
    /**
     Very gentle tap. Used for subtle feedback--things like crossing a swipe boundary
     */
    func gentleInfo() {
        if let engine = hapticEngine {
            let event1 = CHHapticEvent(eventType: .hapticTransient,
                                       parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                                                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.55)],
                                   relativeTime: 0)
            
            playPattern(engine: engine, events: [event1])
        } else {
            print("no engine")
        }
    }
    
    /**
     Stiff gentle tap. Used for subtle feedback on "clickier" things
     */
    func rigidInfo() {
        rigidImpactGenerator.impactOccurred()
    }
    
    // MARK: Success
    
    /**
     Success notification for events that don't need a heavy haptic--votes, saves, etc
     */
    func gentleSuccess() {
        if let engine = hapticEngine {
            let event1 = CHHapticEvent(eventType: .hapticTransient,
                                       parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                                                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.55)],
                                   relativeTime: 0)
            let event2 = CHHapticEvent(eventType: .hapticTransient,
                                       parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.75),
                                                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)],
                                   relativeTime: 0.1)
            
            playPattern(engine: engine, events: [event1, event2])
        } else {
            print("no engine")
        }
    }
    
    /**
     Standard success notification for rarer, more significant events like posting a post or comment
     */
    func success() {
        if let engine = hapticEngine {
            // NOTE: this sequence is a mirror of destructiveSuccess
            let event1 = CHHapticEvent(eventType: .hapticTransient,
                                       parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                                                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)],
                                   relativeTime: 0)
            
            let event2 = CHHapticEvent(eventType: .hapticTransient,
                                       parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                                                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)],
                                       relativeTime: 0.2)
            
            playPattern(engine: engine, events: [event1, event2])
        } else {
            print("no engine")
        }
    }
    
    /**
     Success notification for destructive events like unsubscribing or deleting
     */
    func destructiveSuccess() {
        if let engine = hapticEngine {
            // NOTE: this sequence is a mirror of success
            let event1 = CHHapticEvent(eventType: .hapticTransient,
                                       parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                                                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)],
                                   relativeTime: 0)
            
            let event2 = CHHapticEvent(eventType: .hapticTransient,
                                       parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                                                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)],
                                   relativeTime: 0.2)
            
            playPattern(engine: engine, events: [event1, event2])
        } else {
            print("no engine")
        }
    }
    
    /**
     Success notification for events like blocking a user, sending a report
     */
    func violentSuccess() {
        if let engine = hapticEngine {
            let event1 = CHHapticEvent(eventType: .hapticTransient,
                                       parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                                                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)],
                                   relativeTime: 0)
            let event2 = CHHapticEvent(eventType: .hapticTransient,
                                       parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                                                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)],
                                   relativeTime: 0.55)
            let event3 = CHHapticEvent(eventType: .hapticTransient,
                                       parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                                                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)],
                                   relativeTime: 0.75)
            let event4 = CHHapticEvent(eventType: .hapticTransient,
                                       parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                                                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)],
                                   relativeTime: 0.76)
            
            playPattern(engine: engine, events: [event1, event2, event3, event4])
        } else {
            print("no engine")
        }
    }
    
    // MARK: Failure

    func error() {
        notificationGenerator.notificationOccurred(.error)
    }
    
    // MARK: - Helpers
    
    func playPattern(engine: CHHapticEngine, events: [CHHapticEvent]) {
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription). Attempting to restart engine.")
            hapticEngine = initEngine()
        }
    }
}
