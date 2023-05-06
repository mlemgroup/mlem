//
//  Comment Parses.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import Foundation
import SwiftyJSON

func parseComments(commentResponse: String, instanceLink: URL) async throws -> [Comment]
{
    var commentTracker: [Comment] = .init()
    
    do
    {
        let parsedJSON: JSON = try parseJSON(from: commentResponse)
        
        let commentArray = parsedJSON["data", "comments"].arrayValue
        
        if instanceLink.absoluteString.contains("v1")
        {
            print("Older API spec")
            
            for comment in commentArray
            {
                let newComment: Comment = Comment(
                    id: comment["id"].intValue,
                    postID: comment["post_id"].intValue,
                    creatorID: comment["creator_id"].intValue,
                    //postName: comment["post_name"].stringValue,
                    parentID: comment["parent_id"].int,
                    content: comment["content"].stringValue,
                    removed: comment["removed"].boolValue,
                    //read: comment["read"].boolValue,
                    published: comment["published"].stringValue,
                    deleted: comment["deleted"].boolValue,
                    updated: comment["updated"].string,
                    apID: comment["ap_id"].url!,
                    local: comment["local"].boolValue,
                    communityID: comment["community_id"].intValue,
                    communityActorID: comment["community_actor_id"].url!,
                    communityLocal: comment["local"].boolValue,
                    communityName: comment["community_name"].stringValue,
                    communityIcon: comment["community_icon"].url,
                    communityHideFromAll: comment["community_hide_from_all"].boolValue,
                    creatorBanned: comment["banned"].boolValue,
                    //bannedFromCommunity: comment["banned_from_community"].boolValue,
                    creatorActorID: comment["creator_actor_id"].url!,
                    creatorLocal: comment["creator_local"].boolValue,
                    creatorName: comment["creator_name"].stringValue,
                    creatorPreferredUsername: comment["creator_preferred_username"].stringValue,
                    creatorPublished: comment["creator_published"].stringValue,
                    creatorAvatar: comment["creator_avatar"].url,
                    score: comment["score"].intValue,
                    upvotes: comment["upvotes"].intValue,
                    downvotes: comment["downvotes"].intValue,
                    //hotRank: comment["hot_rank"].intValue,
                    //hotRankActive: comment["hot_rank_active"].intValue,
                    saved: comment["saved"].boolValue,
                    childCount: nil,
                    //subscribed: comment["subscribed"].boolValue,
                    children: .init()
                )
                
                print("New comment: \(newComment)")
                
                commentTracker.append(
                    newComment
                )
            }
        }
        else
        {
            print("Newer API spec")
            
            for comment in commentArray
            {
                let newComment: Comment = Comment(
                    id: comment["comment", "id"].intValue,
                    postID: comment["post", "id"].intValue,
                    creatorID: comment["comment", "creator_id"].intValue,
                    //postName: <#T##String#>,
                    parentID: nil,
                    content: comment["comment", "content"].stringValue,
                    removed: comment["comment", "removed"].boolValue,
                    //read: comment[""],
                    published: comment["comment", "published"].stringValue,
                    deleted: comment["comment", "deleted"].boolValue,
                    updated: comment["comment", "updated"].string,
                    apID: comment["comment", "ap_id"].url!,
                    local: comment["comment", "local"].boolValue,
                    communityID: comment["community", "id"].intValue,
                    communityActorID: comment["community", "actor_id"].url!,
                    communityLocal: comment["community", "local"].boolValue,
                    communityName: comment["community", "name"].stringValue,
                    communityIcon: comment["community", "icon"].url,
                    communityHideFromAll: comment["community", "hidden"].boolValue,
                    creatorBanned: comment["creator", "banned"].boolValue,
                    creatorActorID: comment["creator", "actor_id"].url!,
                    creatorLocal: comment["creator", "local"].boolValue,
                    creatorName: comment["creator", "name"].stringValue,
                    creatorPreferredUsername: comment["creator", "display_name"].string,
                    creatorPublished: comment["creator", "published"].stringValue,
                    creatorAvatar: comment["creator", "avatar"].url,
                    score: comment["counts", "score"].intValue,
                    upvotes: comment["counts", "upvotes"].intValue,
                    downvotes: comment["counts", "downvotes"].intValue,
                    //hotRank: <#T##Int#>,
                    //hotRankActive: <#T##Int?#>,
                    saved: comment["saved"].boolValue,
                    //subscribed: <#T##Bool?#>,
                    childCount: comment["counts", "child_count"].int
                )
                
                print("New comment: \(newComment)")
                
                commentTracker.append(
                    newComment
                )
            }
        }
        
        return commentTracker
    }
    catch let parsingError
    {
        print("Failed while parsing comment JSON: \(parsingError)")
        throw JSONParsingError.failedToParse
    }
}

