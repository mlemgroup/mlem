//
//  Post Parser.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import Foundation
import SwiftyJSON

func parsePosts(postJSON: JSON) async -> [Post]
{
    var postTracker: [Post] = .init()
    
    let postArray = postJSON[["data", "posts"]].arrayValue
    
    print("Post array: \(postArray)")
    
    for post in postArray
    {
        let newPost: Post = Post(
            id: post["id"].intValue,
            name: post["name"].stringValue,
            url: post["url"].stringValue,
            body: post["body"].stringValue,
            creatorID: post["creator_id"].intValue,
            communityID: post["community_id"].intValue,
            removed: post["removed"].boolValue,
            locked: post["locked"].boolValue,
            published: post["published"].stringValue,
            updated: post["updated"].stringValue,
            deleted: post["deleted"].boolValue,
            nsfw: post["nsfw"].boolValue,
            stickied: post["stickied"].boolValue,
            featured: post["features"].boolValue,
            embedTitle: post["embed_title"].stringValue,
            embedDescription: post["embed_description"].stringValue,
            embedHTML: post["embed_html"].stringValue,
            thumbnailURL: post["thumbnail_url"].stringValue,
            apID: post["ap_id"].stringValue,
            local: post["local"].boolValue,
            creatorName: post["creator_name"].stringValue,
            creatorPreferredUsername: post["creator_preferred_username"].stringValue,
            creatorPublished: post["creator_published"].stringValue,
            creatorAvatar: post["creator_avatar"].stringValue,
            communityActorID: post["community_actor_id"].stringValue,
            communityName: post["community_name"].stringValue,
            communityIcon: post["community_icon"].stringValue,
            communityRemoved: post["community_removed"].boolValue,
            communityDeleted: post["community_deleted"].boolValue,
            communityNsfw: post["community_nsfw"].boolValue,
            communityHideFromAll: post["community_hide_from_all"].boolValue,
            numberOfComments: post["number_of_comments"].intValue,
            score: post["score"].intValue,
            upvotes: post["upvotes"].intValue,
            downvotes: post["downvotes"].intValue,
            hotRank: post["hot_rank"].intValue,
            hotRankActive: post["hot_rank_active"].intValue,
            newestActivityTime: post["newest_activity_time"].stringValue
        )
        
        print("New post: \(newPost)")
        
        postTracker.append(
            newPost
        )
    }
    
    return postTracker
}
