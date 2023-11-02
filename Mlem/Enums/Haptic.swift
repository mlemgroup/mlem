//
//  Haptic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-02.
//

import Foundation

/// Enumerates all custom defined haptics used in the app. The raw value of a case corresponds to the name of the file it is stored in.
enum Haptic: String {
    /// Very gentle tap. Used for subtle feedback--things like crossing a swipe boundary
    case gentleInfo = "Gentle Info"

    /// Mushy, gentle tap. Used for extremely subtle feedback
    case mushyInfo = "Mushy Info"
    
    /// Rigid tap. Used for subtle feedback on "clickier" things
    case rigidInfo = "Rigid Info"
    
    /// Success notification for extremely common, low-priority successes--dropping a widget, upvoting a post
    case lightSuccess = "Light Success"
    
    /// Standard success notification
    /// NOTE: this is a gentleInfo and a firmerInfo played in quick succession
    case success = "Success"
    
    /// Success notification for rarer, more significant events like posting a post or comment
    case heavySuccess = "Heavy Success"
    
    /// Success notification for destructive events like unsubscribing or deleting
    case destructiveSuccess = "Destructive Success"
    
    /// Success notification for events like blocking a user, sending a report
    case violentSuccess = "Violent Success"
    
    /// Failure notification
    case failure = "Failure"
}
