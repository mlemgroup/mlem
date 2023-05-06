//
//  Post.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Foundation
import SwiftUI

struct Post: Codable, Identifiable, Equatable
{
    // This is here to make Post equatable
    static func == (lhs: Post, rhs: Post) -> Bool
    {
        return lhs.id == rhs.id
    }

    let id: Int
    let name: String
    var url: URL?
    let body: String?
    let communityID: Int
    let removed, locked: Bool?
    let published: String
    let updated: String?
    let deleted, nsfw, stickied: Bool
    let embedTitle, embedDescription, embedHTML: String?
    let thumbnailURL: String?
    let apID: String
    let local: Bool
    // let creatorActorID: String
    // let creatorLocal: Bool
    let creatorPublished: String
    // let creatorTags: CreatorTags?
    // let creatorCommunityTags: JSONNull?
    // let banned, bannedFromCommunity: Bool
    // let communityLocal: Bool
    let communityName: String
    let communityIcon: URL?
    let communityRemoved: Bool
    let communityDeleted: Bool
    let communityNsfw: Bool
    let communityHideFromAll: Bool
    let numberOfComments, score, upvotes, downvotes: Int
    let hotRank, hotRankActive: Int?
    let newestActivityTime: String?
    //let userID: Int?
    //let myVote: Bool?
    //let subscribed: Bool?
    //let read: Bool?
    //let saved: Bool?
    
    let author: User
}
