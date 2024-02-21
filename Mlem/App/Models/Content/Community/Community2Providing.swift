//
//  Community2Providing.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation
import SwiftUI

struct ActiveUserCount {
    let sixMonths: Int
    let month: Int
    let week: Int
    let day: Int
    
    static let zero: ActiveUserCount = .init(sixMonths: 0, month: 0, week: 0, day: 0)
}

protocol Community2Providing: Community1Providing {
    var community2: Community2 { get }
    
    var subscribed: Bool { get }
    var favorited: Bool { get }
    var subscriberCount: Int { get }
    var postCount: Int { get }
    var commentCount: Int { get }
    var activeUserCount: ActiveUserCount { get }
}

extension Community2Providing {
    var community1: Community1 { community2.community1 }
    
    var subscribed: Bool { community2.subscribed }
    var favorited: Bool { community2.favorited }
    var subscriberCount: Int { community2.subscriberCount }
    var postCount: Int { community2.postCount }
    var commentCount: Int { community2.commentCount }
    var activeUserCount: ActiveUserCount { community2.activeUserCount }
    
    var subscribed_: Bool? { community2.subscribed }
    var favorited_: Bool? { community2.favorited }
    var subscriberCount_: Int? { community2.subscriberCount }
    var postCount_: Int? { community2.postCount }
    var commentCount_: Int? { community2.commentCount }
    var activeUserCount_: ActiveUserCount? { community2.activeUserCount }
    var subscriptionTier_: SubscriptionTier? { community2.subscriptionTier }
}

extension Community2Providing {
    var subscriptionTier: SubscriptionTier {
        if favorited { return .favorited }
        if subscribed { return .subscribed }
        return .unsubscribed
    }
}
