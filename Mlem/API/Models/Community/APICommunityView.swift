//
//  APICommunityView.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_views_actor::structs::CommunityView
struct APICommunityView: Decodable {
    internal init(
        community: APICommunity = .mock,
        subscribed: APISubscribedStatus = .notSubscribed,
        blocked: Bool = false,
        counts: APICommunityAggregates = .mock
    ) {
        self.community = community
        self.subscribed = subscribed
        self.blocked = blocked
        self.counts = counts
    }
    
    let community: APICommunity
    let subscribed: APISubscribedStatus
    let blocked: Bool
    let counts: APICommunityAggregates
}

extension APICommunityView: Mockable {
    static var mock: APICommunityView = .init()
}

extension APICommunityView: ActorIdentifiable {
    var actorId: URL { community.actorId }
}

extension APICommunityView: Hashable, Equatable, Identifiable {
    var id: Int { hashValue }
    
    static func == (lhs: APICommunityView, rhs: APICommunityView) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(community.id)
        hasher.combine(subscribed)
        hasher.combine(blocked)
    }
}
