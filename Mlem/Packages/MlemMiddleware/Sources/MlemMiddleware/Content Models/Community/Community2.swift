//
//  CommunityTier2.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Observation

@Observable
public final class Community2: Community2Providing {
    public static let tierNumber: Int = 2
    public var community2: Community2 { self }
    public var api: ApiClient

    public let community1: Community1
    
    var subscriptionManager: SyntheticStateManager<SubscriptionModel>
    var subscription: SubscriptionModel { subscriptionManager.displayedValue }
    
    public var favorited: Bool {
        api.subscriptions?.isFavorited(self) ?? false
    }
    
    /// Used to state-fake internally.
    var shouldBeFavorited: Bool = false

    public var postCount: Int
    public var commentCount: Int
    public var activeUserCount: ActiveUserCount

    init(
        api: ApiClient,
        community1: Community1,
        subscription: SubscriptionModel,
        postCount: Int,
        commentCount: Int,
        activeUserCount: ActiveUserCount,
        bannedFromCommunity: Bool?
    ) {
        self.api = api
        self.community1 = community1
        self.subscriptionManager = .init(wrappedValue: subscription, mergeType: .disjunctive)
        self.postCount = postCount
        self.commentCount = commentCount
        self.activeUserCount = activeUserCount
        
        if favorited, !subscribed {
            self.api.subscriptions?.favoriteIDs.remove(id)
        }
        subscriptionManager.onSet = { _, _, _ in
            self.api.subscriptions?.updateCommunitySubscription(community: self)
        }
        self.shouldBeFavorited = favorited
        subscriptionManager.onSet(subscription, .receive, nil)
        if let bannedFromCommunity {
            api.myPerson?.updateKnownCommunityBanState(id: id, banned: bannedFromCommunity)
        }
    }
}
