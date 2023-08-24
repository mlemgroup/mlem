//
//  APICommunityView+Mock.swift
//  Mlem
//
//  Created by mormaer on 20/08/2023.
//
//

import Foundation

extension APICommunityView {
    static func mock(
        community: APICommunity = .mock(),
        subscribed: APISubscribedStatus = .notSubscribed,
        blocked: Bool = false,
        counts: APICommunityAggregates = .mock()
    ) -> APICommunityView {
        .init(
            community: community,
            subscribed: subscribed,
            blocked: blocked,
            counts: counts
        )
    }
}
