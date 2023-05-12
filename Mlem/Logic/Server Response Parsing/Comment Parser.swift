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
    var commentTracker: Set<Comment> = .init()
    
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
                    //bannedFromCommunity: comment["banned_from_community"].boolValue,
                    creatorPublished: comment["creator_published"].stringValue,
                    score: comment["score"].intValue,
                    upvotes: comment["upvotes"].intValue,
                    downvotes: comment["downvotes"].intValue,
                    //hotRank: comment["hot_rank"].intValue,
                    //hotRankActive: comment["hot_rank_active"].intValue,
                    saved: comment["saved"].boolValue,
                    author: User(
                        id: 0,
                        name: comment["creator_name"].stringValue,
                        displayName: comment["creator_preferred_username"].stringValue,
                        avatarLink: comment["creator_avatar"].url,
                        bannerLink: nil,
                        inboxLink: nil,
                        bio: nil,
                        banned: comment["banned"].boolValue,
                        actorID: comment["creator_actor_id"].url!,
                        local: comment["creator_local"].boolValue,
                        deleted: false,
                        admin: false,
                        bot: false,
                        onInstanceID: 0
                    ),
                    childCount: nil,
                    //subscribed: comment["subscribed"].boolValue,
                    children: .init()
                )
                
                print("New comment: \(newComment)")
                
                commentTracker.insert(
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
                    parentID: {
                        let stringRepresentationOfPath: String = comment["comment", "path"].stringValue
                        let componentsOfPath = stringRepresentationOfPath.components(separatedBy: ".")
                        
                        if componentsOfPath.count == 2 /// If there are two elements, it'ß the root (0) and the comment itself. That means there is no parent and parentID should be nil
                        {
                            return nil
                        }
                        else
                        {
                            return Int(componentsOfPath.last!)
                        }
                    }(),
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
                    creatorPublished: comment["creator", "published"].stringValue,
                    score: comment["counts", "score"].intValue,
                    upvotes: comment["counts", "upvotes"].intValue,
                    downvotes: comment["counts", "downvotes"].intValue,
                    //hotRank: <#T##Int#>,
                    //hotRankActive: <#T##Int?#>,
                    saved: comment["saved"].boolValue,
                    author: User(
                        id: comment["creator", "id"].intValue,
                        name: comment["creator", "name"].stringValue,
                        displayName: comment["creator", "display_name"].string,
                        avatarLink: comment["creator", "avatar"].url,
                        bannerLink: comment["creator", "banner"].url,
                        inboxLink: comment["creator", "inbox_url"].url,
                        bio: comment["creator", "bio"].stringValue,
                        banned: comment["creator", "banned"].boolValue,
                        actorID: comment["creator", "actor_id"].url!,
                        local: comment["creator", "local"].boolValue,
                        deleted: comment["creator", "deleted"].boolValue,
                        admin: comment["creator", "admin"].boolValue,
                        bot: comment["creator", "bot_account"].boolValue,
                        onInstanceID: comment["creator", "instance_id"].intValue
                    ),
                    //subscribed: <#T##Bool?#>,
                    childCount: comment["counts", "child_count"].int
                )
                
                print("New comment: \(newComment)")
                
                commentTracker.insert(
                    newComment
                )
            }
        }
                
        print("Comment set: \(commentTracker)")
        
        let topLevelComments: [Comment] = commentTracker.filter({ $0.parentID == nil }) /// First, get all the comments with no parentID. Those will be the root of all other comments
        for topLevelComment in topLevelComments {
            commentTracker.remove(topLevelComment) /// Remove all the top level comments from the initial set
        }
        
        var finalComments: [Comment] = topLevelComments /// Create a final array of all the comments. Here, set it to all the top-level comments
        
        print("Found these parent comments \(finalComments.count): \(finalComments)")
        
        while !commentTracker.isEmpty
        { /// These comments should have a parentID
            for comment in finalComments
            {
                
                let matchedComment: Comment = finalComments.filter({ $0.id == comment.id }).first!
                let indiceOfMatchedComment: Int = finalComments.firstIndex(of: matchedComment)!
                
                print("Matched this comment: \(matchedComment)")
                
                print("Found indice of matched comment: \(indiceOfMatchedComment)")
                
                finalComments[indiceOfMatchedComment].children?.append(matchedComment)
                
                commentTracker.remove(matchedComment)
            }
        }
        
        return finalComments
    }
    catch let parsingError
    {
        print("Failed while parsing comment JSON: \(parsingError)")
        throw JSONParsingError.failedToParse
    }
}

