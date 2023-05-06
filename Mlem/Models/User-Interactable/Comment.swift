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
    // let postName: String
    let parentID: Int?
    let content: String
    let removed: Bool
    //let read: Bool
    let published: String
    let deleted: Bool?
    let updated: String?
    let apID: URL
    let local: Bool
    let communityID: Int
    let communityActorID: URL
    let communityLocal: Bool
    let communityName: String
    let communityIcon: URL?
    let communityHideFromAll: Bool
    let creatorBanned: Bool
    //let creatorBannedFromCommunity: Bool?
    let creatorActorID: URL
    let creatorLocal: Bool
    let creatorName: String
    let creatorPreferredUsername: String?
    let creatorPublished: String
    let creatorAvatar: URL?
    //let creatorTags: CreatorTags_Comment?
    //let creatorCommunityTags: JSONNull?
    let score: Int
    let upvotes: Int
    let downvotes: Int
    //let hotRank: Int
    //let hotRankActive: Int?
    let saved: Bool?
    //let subscribed: Bool?
    //let userID, myVote: JSONNull?

    let childCount: Int?
    var children: [Comment]?
}
