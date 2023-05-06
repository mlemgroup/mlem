//
//  Post Parser.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import Foundation
import SwiftyJSON

func parsePosts(postResponse: String, instanceLink: URL) async throws -> [Post]
{
    var postTracker: [Post] = .init()
    
    do
    {
        let parsedJSON: JSON = try parseJSON(from: postResponse)
        
        let postArray = parsedJSON["data", "posts"].arrayValue
        
        print("Post array: \(postArray)")
        
        if instanceLink.absoluteString.contains("v1")
        {
            print("Older API spec")
            
            for post in postArray
            {
                let newPost: Post = Post(
                    id: post["id"].intValue,
                    name: post["name"].stringValue,
                    url: post["url"].url,
                    body: post["body"].stringValue,
                    creatorID: post["creator_id"].intValue,
                    communityID: post["community_id"].intValue,
                    removed: post["removed"].boolValue,
                    locked: post["locked"].boolValue,
                    published: post["published"].stringValue,
                    updated: post["updated"].string,
                    deleted: post["deleted"].boolValue,
                    nsfw: post["nsfw"].boolValue,
                    stickied: post["stickied"].boolValue,
                    featured: post["features"].boolValue,
                    embedTitle: post["embed_title"].string,
                    embedDescription: post["embed_description"].string,
                    embedHTML: post["embed_html"].stringValue,
                    thumbnailURL: post["thumbnail_url"].stringValue,
                    apID: post["ap_id"].stringValue,
                    local: post["local"].boolValue,
                    creatorName: post["creator_name"].stringValue,
                    creatorPreferredUsername: post["creator_preferred_username"].stringValue,
                    creatorPublished: post["creator_published"].stringValue,
                    creatorAvatar: post["creator_avatar"].url,
                    communityActorID: post["community_actor_id"].url!,
                    communityName: post["community_name"].stringValue,
                    communityIcon: post["community_icon"].url,
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
        }
        else
        {
            print("Newer API spec")
            
            for post in postArray
            {
                let newPost: Post = Post(
                    id: post["post", "id"].intValue,
                    name: post["post", "name"].stringValue,
                    url: post["post", "url"].url,
                    body: post["post", "body"].stringValue,
                    creatorID: post["creator", "id"].intValue,
                    communityID: post["community", "id"].intValue,
                    removed: post["post", "removed"].boolValue,
                    locked: post["post", "locked"].boolValue,
                    published: post["post", "published"].stringValue,
                    updated: post["post", "updated"].string,
                    deleted: post["post", "deleted"].boolValue,
                    nsfw: post["post", "nsfw"].boolValue,
                    stickied: post["post", "featured_community"].boolValue,
                    featured: post["post", "featured_local"].boolValue,
                    embedTitle: post["post", "embed_title"].string,
                    embedDescription: post["post", "embed_description"].string,
                    embedHTML: nil,
                    thumbnailURL: post["post", "thumbnail_url"].string,
                    apID: post["post", "ap_id"].stringValue,
                    local: post["post", "local"].boolValue,
                    creatorName: post["creator", "name"].stringValue,
                    creatorPreferredUsername: post["creator", "display_name"].string,
                    creatorPublished: post["creator", "published"].stringValue,
                    creatorAvatar: post["creator", "avatar"].url,
                    communityActorID: post["creator", "actor_id"].url!,
                    communityName: post["community", "name"].stringValue,
                    communityIcon: post["community", "icon"].url,
                    communityRemoved: post["community", "removed"].boolValue,
                    communityDeleted: post["community", "deleted"].boolValue,
                    communityNsfw: post["community", "nsfw"].boolValue,
                    communityHideFromAll: post["community", "hidden"].boolValue,
                    numberOfComments: post["counts", "comments"].intValue,
                    score: post["counts", "score"].intValue,
                    upvotes: post["counts", "upvotes"].intValue,
                    downvotes: post["counts", "downvotes"].intValue,
                    hotRank: nil,
                    hotRankActive: nil,
                    newestActivityTime: post["counts", "newest_comment_time"].stringValue
                )
                
                print("New post: \(newPost)")
                
                postTracker.append(
                    newPost
                )
            }
        }
        
        return postTracker
    }
    catch let parsingError
    {
        print("Failed while parsing post response: \(parsingError)")
        throw JSONParsingError.failedToParse
    }
}
