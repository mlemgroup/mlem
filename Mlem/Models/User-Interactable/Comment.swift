//
//  Comment.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Foundation
import SwiftUI


// MARK: - RawResponseComment
struct RawResponseComment: Codable {
    let op: String
    let data: DataClass_Comment
}

// MARK: - DataClass
struct DataClass_Comment: Codable {
    let post: Post_Comment
    let comments: [Comment]
    let community: Community_Comment
    let moderators: [Moderator]
    let online: Int
    let admins, sitemods: [Admin]
}

// MARK: - Admin
struct Admin: Codable {
    let id: Int
    let actorID: String
    let name: String
    let preferredUsername: JSONNull_Comment?
    let avatar: String?
    let banner: JSONNull_Comment?
    let matrixUserID: String?
    let bio: JSONNull_Comment?
    let local, admin, sitemod, moderator: Bool
    let banned: Bool
    let published: String
    let numberOfPosts, numberOfComments: Int

    enum CodingKeys: String, CodingKey {
        case id
        case actorID
        case name
        case preferredUsername
        case avatar, banner
        case matrixUserID
        case bio, local, admin, sitemod, moderator, banned, published
        case numberOfPosts
        case numberOfComments
    }
}

// MARK: - Comment
struct Comment: Codable {
    let id, postID: Int
    let creatorID: Int?
    let postName: String
    let parentID: Int?
    let content: String
    let removed, read: Bool
    let published: String
    let updated: JSONNull_Comment?
    let deleted: Bool
    let apID: String
    let local: Bool
    let communityID: Int?
    let communityActorID: String
    let communityLocal: Bool
    let communityName: String
    let communityIcon: JSONNull_Comment?
    let communityHideFromAll, banned, bannedFromCommunity: Bool
    let creatorActorID: String
    let creatorLocal: Bool
    let creatorName: String
    let creatorPreferredUsername: JSONNull_Comment?
    let creatorPublished: String
    let creatorAvatar: JSONNull_Comment?
    let creatorTags: CreatorTags
    let creatorCommunityTags: JSONNull_Comment?
    let score, upvotes, downvotes, hotRank: Int
    let hotRankActive: Int
    let userID, myVote, subscribed, saved: JSONNull_Comment?

    enum CodingKeys: String, CodingKey {
        case id
        case creatorID
        case postID
        case postName
        case parentID
        case content, removed, read, published, updated, deleted
        case apID
        case local
        case communityID
        case communityActorID
        case communityLocal
        case communityName
        case communityIcon
        case communityHideFromAll
        case banned
        case bannedFromCommunity
        case creatorActorID
        case creatorLocal
        case creatorName
        case creatorPreferredUsername
        case creatorPublished
        case creatorAvatar
        case creatorTags
        case creatorCommunityTags
        case score, upvotes, downvotes
        case hotRank
        case hotRankActive
        case userID
        case myVote
        case subscribed, saved
    }
}

// MARK: - CreatorTags
struct CreatorTags_Comment: Codable {
    let pronouns: String
}

// MARK: - Community
struct Community_Comment: Codable {
    let id: Int
    let name, title: String
    let icon, banner: JSONNull_Comment?
    let communityDescription: String
    let categoryID: Int
    let creatorID: Int?
    let removed: Bool
    let published: String
    let updated: String?
    let deleted, nsfw: Bool
    let actorID: String
    let local: Bool
    let lastRefreshedAt: String
    let creatorActorID: String
    let creatorLocal: Bool
    let creatorName: String
    let creatorPreferredUsername, creatorAvatar: JSONNull_Comment?
    let categoryName: String
    let numberOfSubscribers, numberOfPosts, numberOfComments, hotRank: Int
    let userID, subscribed: JSONNull_Comment?

    enum CodingKeys: String, CodingKey {
        case id, name, title, icon, banner
        case communityDescription
        case categoryID
        case creatorID
        case removed, published, updated, deleted, nsfw
        case actorID
        case local
        case lastRefreshedAt
        case creatorActorID
        case creatorLocal
        case creatorName
        case creatorPreferredUsername
        case creatorAvatar
        case categoryName
        case numberOfSubscribers
        case numberOfPosts
        case numberOfComments
        case hotRank
        case userID
        case subscribed
    }
}

// MARK: - Moderator
struct Moderator: Codable {
    let id, userID: Int
    let communityID: Int?
    let published: String
    let userActorID: String
    let userLocal: Bool
    let userName: String
    let userPreferredUsername, avatar: JSONNull_Comment?
    let communityActorID: String
    let communityLocal: Bool
    let communityName: String
    let communityIcon: JSONNull_Comment?

    enum CodingKeys: String, CodingKey {
        case id
        case communityID
        case userID
        case published
        case userActorID
        case userLocal
        case userName
        case userPreferredUsername
        case avatar
        case communityActorID
        case communityLocal
        case communityName
        case communityIcon
    }
}

// MARK: - Post
struct Post_Comment: Codable {
    let id: Int
    let name: String
    let url: String
    let body: JSONNull_Comment?
    let creatorID: Int?
    let communityID: Int?
    let removed, locked: Bool
    let published: String
    let updated: JSONNull_Comment?
    let deleted, nsfw, stickied, featured: Bool
    let embedTitle, embedDescription: JSONNull_Comment?
    let embedHTML: String
    let thumbnailURL: String
    let apID: String
    let local: Bool
    let creatorActorID: String
    let creatorLocal: Bool
    let creatorName: String
    let creatorPreferredUsername: JSONNull_Comment?
    let creatorPublished: String
    let creatorAvatar: JSONNull_Comment?
    let creatorTags: CreatorTags
    let creatorCommunityTags: JSONNull_Comment?
    let banned, bannedFromCommunity: Bool
    let communityActorID: String
    let communityLocal: Bool
    let communityName: String
    let communityIcon: JSONNull_Comment?
    let communityRemoved, communityDeleted, communityNsfw, communityHideFromAll: Bool
    let numberOfComments, score, upvotes, downvotes: Int
    let hotRank, hotRankActive: Int
    let newestActivityTime: String
    let userID, myVote, subscribed, read: JSONNull_Comment?
    let saved: JSONNull_Comment?

    enum CodingKeys: String, CodingKey {
        case id, name, url, body
        case creatorID
        case communityID
        case removed, locked, published, updated, deleted, nsfw, stickied, featured
        case embedTitle
        case embedDescription
        case embedHTML
        case thumbnailURL
        case apID
        case local
        case creatorActorID
        case creatorLocal
        case creatorName
        case creatorPreferredUsername
        case creatorPublished
        case creatorAvatar
        case creatorTags
        case creatorCommunityTags
        case banned
        case bannedFromCommunity
        case communityActorID
        case communityLocal
        case communityName
        case communityIcon
        case communityRemoved
        case communityDeleted
        case communityNsfw
        case communityHideFromAll
        case numberOfComments
        case score, upvotes, downvotes
        case hotRank
        case hotRankActive
        case newestActivityTime
        case userID
        case myVote
        case subscribed, read, saved
    }
}

// MARK: - Encode/decode helpers

class JSONNull_Comment: Codable, Hashable {

    public static func == (lhs: JSONNull_Comment, rhs: JSONNull_Comment) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull_Comment.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}


// MARK: Můj kód
/*func decodeRawCommentJSON(rawJSON: String) -> [Comment] {
    
    // TODO: Convert this into an Observable Object in case I need to do any more data pulling on the way
    
    let decodedCommentsReturner: [Comment]
    
    do {
        let decoder = JSONDecoder()
        let decodedComments = try? decoder.decode(RawResponseComment.self, from: rawJSON.data(using: .utf8)!)
        
        print("Decoding comment JSON:")
        print(rawJSON)
        
        print("Into comment objects:")
        print(decodedComments!)
        
        decodedCommentsReturner = (decodedComments?.data.comments)!
    } catch {
        print("Failed to decode: \(error)")
    }
    
    return decodedCommentsReturner
}
*/

func decodeRawCommentJSON(commentRawData: String) -> Void {
    if commentRawData == nil {
        
    } else {
        var decodedCommentsReturner = [Comment]()
        do {
            let decoder = JSONDecoder()
            let decodedComments = try decoder.decode(RawResponseComment.self, from: commentRawData.data(using: .utf8)!)
            
            print("Decoding comment JSON: \(commentRawData)")
            
            print("Into comment objects: \(decodedComments)")
            
            var decodedCommentsReturner = (decodedComments.data.comments)
        } catch {
            print("Failed to decode: \(error)")
        }
    }
}
