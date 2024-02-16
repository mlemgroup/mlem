//
//  APIPostView.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_views::structs::PostView
struct APIPostView: Decodable, APIContentViewProtocol {
    internal init(
        post: APIPost = .mock,
        creator: APIPerson = .mock,
        community: APICommunity = .mock,
        creatorBannedFromCommunity: Bool = false,
        creatorIsModerator: Bool? = nil,
        creatorIsAdmin: Bool? = nil,
        counts: APIPostAggregates = .mock,
        subscribed: APISubscribedStatus = .notSubscribed,
        saved: Bool = false,
        read: Bool = false,
        creatorBlocked: Bool = false,
        myVote: ScoringOperation? = nil,
        unreadComments: Int = 0
    ) {
        self.post = post
        self.creator = creator
        self.community = community
        self.creatorBannedFromCommunity = creatorBannedFromCommunity
        self.creatorIsModerator = creatorIsModerator
        self.creatorIsAdmin = creatorIsAdmin
        self.counts = counts
        self.subscribed = subscribed
        self.saved = saved
        self.read = read
        self.creatorBlocked = creatorBlocked
        self.myVote = myVote
        self.unreadComments = unreadComments
    }
    
    let post: APIPost
    let creator: APIPerson
    let community: APICommunity
    let creatorBannedFromCommunity: Bool
    let creatorIsModerator: Bool? // TODO: 0.18 deprecation make this field non-optional
    let creatorIsAdmin: Bool? // TODO: 0.18 deprecation make this field non-optional
    var counts: APIPostAggregates
    let subscribed: APISubscribedStatus
    let saved: Bool
    let read: Bool
    let creatorBlocked: Bool
    var myVote: ScoringOperation?
    let unreadComments: Int
}

extension APIPostView: Mockable {
    static var mock: APIPostView { .init() }
}

extension APIPostView: Identifiable, ActorIdentifiable {
    var id: Int { post.id }
    var actorId: URL { post.apId }
}

extension APIPostView: Equatable {
    static func == (lhs: APIPostView, rhs: APIPostView) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension APIPostView: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(post.id)
        hasher.combine(myVote)
        hasher.combine(saved)
        hasher.combine(read)
        hasher.combine(post.updated)
    }
}
