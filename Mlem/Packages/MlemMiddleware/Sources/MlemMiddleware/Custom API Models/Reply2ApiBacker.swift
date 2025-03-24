//
//  Reply2ApiBacker.swift
//
//
//  Created by Sjmarf on 05/07/2024.
//

import Foundation

/// This protocol is conformed to be ``ApiCommentReplyView`` and ``ApiPersonMentionView``.
public protocol Reply2ApiBacker: CacheIdentifiable, Identifiable {
    var reply: any Reply1ApiBacker { get }
    var comment: ApiComment { get }
    var creator: ApiPerson { get }
    var post: ApiPost { get }
    var community: ApiCommunity { get }
    var recipient: ApiPerson { get }
    var creatorBannedFromCommunity: Bool { get }
    var subscribed: ApiSubscribedType { get }
    var creatorBlocked: Bool { get }
    var myVote: Int? { get }
    /// Added in 0.19.0
    var creatorIsModerator: Bool? { get }
    /// Added in 0.19.0
    var creatorIsAdmin: Bool? { get }
    /// Added in 0.19.4
    var bannedFromCommunity: Bool? { get }
    var counts: ApiCommentAggregates { get }
    
    var resolvedSaved: Bool { get }
}

public extension Reply2ApiBacker {
    var cacheId: Int { reply.id }
    var id: Int { reply.id }
}
