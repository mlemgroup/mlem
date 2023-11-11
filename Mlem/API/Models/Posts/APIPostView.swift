//
//  APIPostView.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_views::structs::PostView
struct APIPostView: Decodable, APIContentViewProtocol {
    let post: APIPost
    let creator: APIPerson
    let community: APICommunity
    let creatorBannedFromCommunity: Bool
    // TODO: 0.18 Deprecation make this field non-optional
    let creatorIsModerator: Bool?
    var counts: APIPostAggregates
    let subscribed: APISubscribedStatus
    let saved: Bool
    let read: Bool
    let creatorBlocked: Bool
    var myVote: ScoringOperation?
    let unreadComments: Int
}

extension APIPostView: Identifiable {
    var id: Int { hashValue }
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

// MARK: - FeedTrackerItem

extension APIPostView: FeedTrackerItem {
    var uniqueIdentifier: some Hashable { post.id }
    var published: Date { post.published }
}
