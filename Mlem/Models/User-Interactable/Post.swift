//
//  Post.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Foundation
import SwiftUI

struct Post: Codable, Identifiable, Equatable, Hashable
{
    // This is here to make Post equatable
    static func == (lhs: Post, rhs: Post) -> Bool
    {
        return lhs.hashValue == rhs.hashValue
    }

    let id: Int
    var name: String
    var url: URL?
    let body: String?
    let removed, locked: Bool?
    let published: Date
    let updated: String?
    let deleted, nsfw, stickied: Bool
    let embedTitle, embedDescription, embedHTML: String?
    let thumbnailURL: URL?
    let apID: String
    let local: Bool
    // let creatorActorID: String
    // let creatorLocal: Bool
    let postedAt: String
    // let creatorTags: CreatorTags?
    // let creatorCommunityTags: JSONNull?
    // let banned, bannedFromCommunity: Bool
    var numberOfComments, score, upvotes, downvotes: Int
    var myVote: MyVote
    let hotRank, hotRankActive: Int?
    let newestActivityTime: String?
    //let userID: Int?
    //let subscribed: Bool?
    //let read: Bool?
    
    var saved: Bool
    var read: Bool
    
    var unreadComments: Int
    
    
    let author: User
    
    let community: Community
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(updated)
        hasher.combine(deleted)
        hasher.combine(postedAt)
        hasher.combine(myVote)
        hasher.combine(saved)
        hasher.combine(read)
        hasher.combine(unreadComments)
    }
}
