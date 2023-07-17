//
//  Haptic Manager.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-17.
//

import Foundation
import SwiftUI

class HapticManager {
    
    let lightImpactGenerator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    let rigidImpactGenerator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    let notificationGenerator: UINotificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
    static let shared = HapticManager()
    
    private init() {}
    
    // MARK: Informative
    
    /**
     Very gentle tap. Used for subtle feedback--things like crossing a swipe boundary
     */
    func gentleInfo() {
        lightImpactGenerator.impactOccurred()
    }
    
    /**
     Stiff gentle tap. Used for subtle feedback on "clickier" things
     */
    func rigidInfo() {
        rigidImpactGenerator.impactOccurred()
    }
    
    // MARK: Success
    
    /**
     Standard success notification for rarer, more significant events like posting a post or comment
     */
    func success() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    /**
     Success notification for events that don't need a heavy haptic--votes, saves, etc
     */
    func gentleSuccess() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    /**
     Success notification for destructive events like unsubscribing or deleting
     */
    func destructiveSuccess() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    /**
     Success notification for events like blocking a user, sending a report
     */
    func violentSuccess() {
        notificationGenerator.notificationOccurred(.warning)
    }
    
    // MARK: Failure

    func error() {
        notificationGenerator.notificationOccurred(.error)
    }
}
