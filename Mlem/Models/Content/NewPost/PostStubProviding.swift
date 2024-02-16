//
//  PostStubProviding.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

protocol PostStubProviding: ContentStub {
    // From Post1Providing. These are defined as nil in the extension below
    var id: Int? { get }
    var title: String? { get }
    var content: String? { get }
    var deleted: Bool? { get }
    var embed: PostEmbed? { get }
    var pinnedCommunity: Bool? { get }
    var pinnedInstance: Bool? { get }
    var locked: Bool? { get }
    var nsfw: Bool? { get }
    var creationDate: Date? { get }
    var removed: Bool? { get }
    var thumbnailUrl: URL? { get }
    var updatedDate: Date? { get }
    
    // From Post2Providing. These are defined as nil in the extension below
    var creator: User1? { get }
    var community: Community1? { get }
    var commentCount: Int? { get }
    var upvoteCount: Int? { get }
    var downvoteCount: Int? { get }
    var unreadCommentsCount: Int? { get }
    var isSaved: Bool? { get }
    var isRead: Bool? { get }
    var myVote: ScoringOperation? { get }
}

extension PostStubProviding {
    var id: Int? { nil }
    var title: String? { nil }
    var content: String? { nil }
    var deleted: Bool? { nil }
    var embed: PostEmbed? { nil }
    var pinnedCommunity: Bool? { nil }
    var pinnedInstance: Bool? { nil }
    var locked: Bool? { nil }
    var nsfw: Bool? { nil }
    var creationDate: Date? { nil }
    var removed: Bool? { nil }
    var thumbnailUrl: URL? { nil }
    var updatedDate: Date? { nil }
    
    var creator: User1? { nil }
    var community: Community1? { nil }
    var commentCount: Int? { nil }
    var upvoteCount: Int? { nil }
    var downvoteCount: Int? { nil }
    var unreadCommentsCount: Int? { nil }
    var isSaved: Bool? { nil }
    var isRead: Bool? { nil }
    var myVote: ScoringOperation? { nil }
}
