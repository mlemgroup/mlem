//
//  APICommentView.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_views::structs::CommentView
struct APICommentView: Decodable, APIContentViewProtocol {
    internal init(
        comment: APIComment = .mock,
        creator: APIPerson = .mock,
        post: APIPost = .mock,
        community: APICommunity = .mock,
        counts: APICommentAggregates = .mock,
        creatorBannedFromCommunity: Bool = false,
        creatorIsModerator: Bool? = nil,
        creatorIsAdmin: Bool? = nil,
        subscribed: APISubscribedStatus = .notSubscribed,
        saved: Bool = false,
        creatorBlocked: Bool = false,
        myVote: ScoringOperation? = nil
    ) {
        self.comment = comment
        self.creator = creator
        self.post = post
        self.community = community
        self.counts = counts
        self.creatorBannedFromCommunity = creatorBannedFromCommunity
        self.creatorIsModerator = creatorIsModerator
        self.creatorIsAdmin = creatorIsAdmin
        self.subscribed = subscribed
        self.saved = saved
        self.creatorBlocked = creatorBlocked
        self.myVote = myVote
    }
    
    let comment: APIComment
    let creator: APIPerson
    let post: APIPost
    let community: APICommunity
    let counts: APICommentAggregates
    let creatorBannedFromCommunity: Bool
    let creatorIsModerator: Bool? // TODO: 0.18 deprecation make this field non-optional
    let creatorIsAdmin: Bool? // TODO: 0.18 deprecation make this field non-optional
    let subscribed: APISubscribedStatus
    let saved: Bool
    let creatorBlocked: Bool
    var myVote: ScoringOperation?
}

extension APICommentView: Mockable {
    static var mock: APICommentView { .init() }
}

extension APICommentView: Identifiable {
    // defer to our contained comment for identity
    var id: Int { comment.id }
}

extension APICommentView: Equatable {
    static func == (lhs: APICommentView, rhs: APICommentView) -> Bool {
        // defer to our child comment for equality
        lhs.comment.id == rhs.comment.id
    }
}
