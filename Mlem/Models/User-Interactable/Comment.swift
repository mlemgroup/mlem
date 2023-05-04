//
//  Comment.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Foundation
import SwiftUI

struct Comment: Codable, Identifiable
{
    let id: Int
    let postID: Int
    let creatorID: Int
    let postName: String
    let parentID: Int?
    let content: String
    let removed: Bool
    let read: Bool
    let published: String
    let deleted: Bool?
    let updated: String?
    let apID: String
    let local: Bool
    let communityID: Int
    let communityActorID: String
    let communityLocal: Bool
    let communityName: String
    let communityIcon: String?
    let communityHideFromAll: Bool
    let banned: Bool
    let bannedFromCommunity: Bool?
    let creatorActorID: String
    let creatorLocal: Bool
    let creatorName: String
    let creatorPreferredUsername: String?
    let creatorPublished: String
    let creatorAvatar: String?
    //let creatorTags: CreatorTags_Comment?
    //let creatorCommunityTags: JSONNull?
    let score: Int
    let upvotes: Int
    let downvotes: Int
    let hotRank: Int
    let hotRankActive: Int?
    let saved: Bool?
    let subscribed: Bool?
    //let userID, myVote: JSONNull?

    let children: [Comment]?
}
