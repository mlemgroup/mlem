//
//  SubscriptionModel.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 08/08/2024.
//

import Foundation

public struct SubscriptionModel: Hashable, MergeableValue {
    // These are the values actually provided by the API.
    var actualTotal: Int
    var actualLocal: Int?
    
    public var subscribed: Bool
    
    // When you subscribe, your instance asks the community host to confirm the subscription.
    // Until a confirmation is received from the host, the subscription state is
    // `LemmySubscribedType.pending`. The subscription count of the community doesn't change
    // until the subscription status is confirmed by the community host. There also appears
    // to exist a "pending" state for unsubscribing, but the API doesn't tell us when it's
    // in this state.
    //
    // This property is "true" when the subscription is thought to be pending in **either**
    // direction. Because we don't actually know whether an unsubscription is pending, this
    // may not always be accurate.
    var pending: Bool
    
    // This accounts for the `actualTotal` not taking your own pending subscription into account.
    public var total: Int { actualTotal + pendingSubscriptionValue }
    
    // This accounts for the `actualLocal` not taking your own pending subscription into account.
    /// Added in 0.19.4.
    public var local: Int? {
        guard let actualLocal else { return nil }
        return actualLocal + pendingSubscriptionValue
    }
    
    public func merge(with other: SubscriptionModel, using mergeType: ValueMergeType) -> SubscriptionModel {
        switch mergeType {
        case .disjunctive:
            .init(
                total: max(total, other.total),
                local: nil,
                subscribed: subscribed || other.subscribed,
                pending: pending || other.pending
            )
        case .conjunctive:
            .init(
                total: max(total, other.total),
                local: nil,
                subscribed: subscribed && other.subscribed,
                pending: pending && other.pending
            )
        }
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

    init(total: Int, local: Int?, subscribed: Bool, pending: Bool) {
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
    var subscribedType: LemmySubscribedType {
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
