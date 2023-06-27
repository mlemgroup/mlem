//
//  Comment.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Foundation
import SwiftUI

struct Comment: Codable, Identifiable, Hashable {
    let id: Int
    let postID: Int
    let creatorID: Int
    // let postName: String
    let parentID: Int?
    var content: String
    var removed: Bool
    // let read: Bool
    let published: Date
    var deleted: Bool?
    let updated: String?
    let apID: URL
    let local: Bool
    let communityID: Int
    let communityLocal: Bool
    let communityName: String
    let communityIcon: URL?
    let communityHideFromAll: Bool
    // let creatorBannedFromCommunity: Bool?
    let creatorPublished: String
    // let creatorTags: CreatorTags_Comment?
    // let creatorCommunityTags: JSONNull?
    var score: Int
    var upvotes: Int
    var downvotes: Int
    var myVote: MyVote
    // let hotRank: Int
    // let hotRankActive: Int?
    let saved: Bool?
    // let subscribed: Bool?
    // let userID, myVote: JSONNull?

    let author: User

    let childCount: Int?
    var children: [Comment]

    func insertReply(_ reply: Comment) -> Comment {
        if id == reply.parentID {
            var result = self
            result.children.append(reply)
            return result
        } else if children.isEmpty {
            return self
        } else {
            var result = self
            result.children = children.map { $0.insertReply(reply) }
            return result
        }
    }

    /// Locate the reply with the matching ID in the Comment tree
    /// and replace it with the specified reply. Note that this
    /// cannot change the parent of the reply!
    func replaceReply(_ reply: Comment) -> Comment {
        if id == reply.id {
            assert(parentID == reply.parentID)
            return reply
        } else if children.isEmpty {
            return self
        } else {
            var result = self
            result.children = children.map { $0.replaceReply(reply) }
            return result
        }
    }

    /// Remove the reply with the specified ID from the Comment tree,
    /// along with all of its descendents.
    func removeReply(id: Int) -> Comment? {
        if self.id == id {
            return nil
        } else if children.isEmpty {
            return self
        } else {
            var result = self
            result.children = children.compactMap { $0.removeReply(id: id) }
            return result
        }
    }
}
