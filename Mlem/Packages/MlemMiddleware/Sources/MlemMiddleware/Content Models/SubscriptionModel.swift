//
//  SubscriptionModel.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 08/08/2024.
//

import Foundation

public struct SubscriptionModel: Hashable, Equatable {
    // These are the values actually provided by the API.
    var actualTotal: Int
    var actualLocal: Int?
    
    var subscribed: Bool
    
    // When you subscribe, your instance asks the community host to confirm the subscription.
    // Until a confirmation is received from the host, the subscription state is
    // `ApiSubscribedType.pending`. The subscription count of the community doesn't change
    // until the subscription status is confirmed by the community host. There also appears
    // to exist a "pending" state for unsubscribing, but the API doesn't tell us when it's
    // in this state.
    //
    // This property is "true" when the subscription is thought to be pending in **either**
    // direction. Because we don't actually know whether an unsubscription is pending, this
    // may not always be accurate.
    var pending: Bool
    
    // This accounts for the `actualTotal` not taking your own pending subscription into account.
    var total: Int { actualTotal + pendingSubscriptionValue }
    
    // This accounts for the `actualLocal` not taking your own pending subscription into account.
    /// Added in 0.19.4.
    var local: Int? {
        guard let actualLocal else { return nil }
        return actualLocal + pendingSubscriptionValue
    }
    
    private var pendingSubscriptionValue: Int {
        switch (subscribed, pending) {
        case (true, true):
            return 1
        case (false, true):
            return -1
        case (_, false):
            return 0
        }
    }
    
    init(from aggregates: ApiCommunityAggregates, subscribedType: ApiSubscribedType) {
        self.actualTotal = aggregates.subscribers
        self.actualLocal = aggregates.subscribersLocal
        self.subscribed = subscribedType.isSubscribed
        self.pending = subscribedType == .pending
    }
    
    @available(*, deprecated)
    init(from aggregates: ApiCommunityAggregates?, subscribedType: ApiSubscribedType) {
        self.actualTotal = aggregates?.subscribers ?? 0
        self.actualLocal = aggregates?.subscribersLocal ?? 0
        self.subscribed = subscribedType.isSubscribed
        self.pending = subscribedType == .pending
    }

    init(total: Int, local: Int? = nil, subscribed: Bool, pending: Bool) {
        self.actualTotal = total
        self.actualLocal = local
        self.subscribed = subscribed
        self.pending = pending
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(actualTotal)
        hasher.combine(actualLocal)
        hasher.combine(subscribed)
        hasher.combine(pending)
    }
    
    public static func == (lhs: SubscriptionModel, rhs: SubscriptionModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension SubscriptionModel {
    var subscribedType: ApiSubscribedType {
        if subscribed {
            pending ? .pending : .subscribed
        } else {
            .notSubscribed
        }
    }
    
    func withSubscriptionStatus(subscribed shouldSubscribe: Bool, isLocal: Bool) -> SubscriptionModel {
        guard shouldSubscribe != subscribed else { return self }
        
        let diff: Int
        if isLocal {
            diff = shouldSubscribe ? 1 : -1
        } else {
            diff = 0
        }
        
        let newLocal: Int?
        if let actualLocal {
            newLocal = actualLocal + diff
        } else {
            newLocal = nil
        }
        
        return SubscriptionModel(
            total: actualTotal + diff,
            local: newLocal,
            subscribed: shouldSubscribe,
            pending: !(pending || isLocal)
        )
    }
}
