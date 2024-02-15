//
//  Community2Providing.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation
import SwiftUI

protocol Community2Providing: Community1Providing {
    var community2: Community2 { get }
    
    var subscribed: Bool { get }
    var blocked: Bool { get }
    var favorited: Bool { get }
    
    var subscriberCount: Int { get }
    var postCount: Int { get }
    var commentCount: Int { get }
    var activeUserCount: ActiveUserCount { get }
}

extension Community2Providing {
    var subscriberCount: Int { community2.subscriberCount }
    var postCount: Int { community2.postCount }
    var commentCount: Int { community2.commentCount }
    var activeUserCount: ActiveUserCount { community2.activeUserCount }
}

enum SubscriptionTier {
    case unsubscribed, subscribed, favorited
    
    var foregroundColor: Color {
        switch self {
        case .unsubscribed:
            return .secondary
        case .subscribed:
            return .green
        case .favorited:
            return .blue
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .unsubscribed:
            return .secondary
        case .subscribed:
            return .green
        case .favorited:
            return .clear
        }        
    }
    
    var systemImage: String {
        switch self {
        case .unsubscribed:
            return Icons.personFill
        case .subscribed:
            return Icons.successCircle
        case .favorited:
            return Icons.favoriteFill
        }
    }
}

extension Community2Providing {
    var subscriptionStatus: SubscriptionTier {
        if favorited { return .favorited }
        if subscribed { return .subscribed }
        return .unsubscribed
    }
}
