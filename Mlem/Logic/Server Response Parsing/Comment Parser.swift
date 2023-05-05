//
//  Comment Parses.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import Foundation
import SwiftyJSON

func parseComments(commentResponse: String) async throws -> [Comment]
{
    var commentTracker: [Comment] = .init()
    
    do
    {
        let parsedJSON: JSON = try parseJSON(from: commentResponse)
        
        let commentArray = parsedJSON["data", "comments"].arrayValue
        
        for comment in commentArray
        {
            let newComment: Comment = Comment(
                id: comment["id"].intValue,
                postID: comment["post_id"].intValue,
                creatorID: comment["creator_id"].intValue,
                postName: comment["post_name"].stringValue,
                parentID: comment["parent_id"].int,
                content: comment["content"].stringValue,
                removed: comment["removed"].boolValue,
                read: comment["read"].boolValue,
                published: comment["published"].stringValue,
                deleted: comment["deleted"].boolValue,
                updated: comment["updated"].stringValue,
                apID: comment["ap_id"].stringValue,
                local: comment["local"].boolValue,
                communityID: comment["community_id"].intValue,
                communityActorID: comment["community_actor_id"].stringValue,
                communityLocal: comment["local"].boolValue,
                communityName: comment["community_name"].stringValue,
                communityIcon: comment["community_icon"].stringValue,
                communityHideFromAll: comment["community_hide_from_all"].boolValue,
                banned: comment["banned"].boolValue,
                bannedFromCommunity: comment["banned_from_community"].boolValue,
                creatorActorID: comment["creator_actor_id"].stringValue,
                creatorLocal: comment["creator_local"].boolValue,
                creatorName: comment["creator_name"].stringValue,
                creatorPreferredUsername: comment["creator_preferred_username"].stringValue,
                creatorPublished: comment["creator_published"].stringValue,
                creatorAvatar: comment["creator_avatar"].stringValue,
                score: comment["score"].intValue,
                upvotes: comment["upvotes"].intValue,
                downvotes: comment["downvotes"].intValue,
                hotRank: comment["hot_rank"].intValue,
                hotRankActive: comment["hot_rank_active"].intValue,
                saved: comment["saved"].boolValue,
                subscribed: comment["subscribed"].boolValue,
                children: .init()
            )
            
            print("New comment: \(newComment)")
            
            commentTracker.append(
                newComment
            )
        }
        
        return commentTracker
    }
    catch let parsingError
    {
        print("Failed while parsing comment JSON: \(parsingError)")
        throw JSONParsingError.failedToParse
    }
}

