//
//  Haptic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-02.
//

import Foundation

/**
 Enumerates all custom defined haptics used in the app. The raw value of a case corresponds to the name of the file it is stored in.
 */
enum Haptic: String {
    /**
     Very gentle tap. Used for subtle feedback--things like crossing a swipe boundary
     */
    case gentleInfo = "Gentle Info"
    
    /**
     Firmer tap. Used for slightly less subtle feedback
     */
    case firmerInfo = "Firmer Info"
    
    /**
     Mushy, gentle tap. Used for extremely subtle feedback
     */
    case mushyInfo = "Mushy Info"
    
    /**
     Rigid tap. Used for subtle feedback on "clickier" things
     */
    case rigidInfo = "Rigid Info"
    
    /**
     Success notification for events that don't need a heavy haptic--votes, saves, etc
     
     NOTE: this is a gentleInfo and a firmerInfo played in quick succession
     */
    case gentleSuccess = "Gentle Success"
    
    /**
     Standard success notification for rarer, more significant events like posting a post or comment
     */
    case success = "Success"
    
    /**
     Success notification for destructive events like unsubscribing or deleting
     */
    case destructiveSuccess = "Destructive Success"
    
    /**
     Success notification for events like blocking a user, sending a report
     */
    case violentSuccess = "Violent Success"
    
    /**
     Failure notification
     */
    case failure = "Failure"
}
