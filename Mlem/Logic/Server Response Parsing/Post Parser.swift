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
        
        var postArray = parsedJSON["data", "posts"].arrayValue
        
        if postArray.isEmpty
        {
            postArray = [parsedJSON["data", "post_view"]]
        }
        
        //print("Post array: \(postArray)")
        
        for post in postArray
        {
            let newPost: Post = Post(
                id: post["post", "id"].intValue,
                name: post["post", "name"].stringValue,
                url: post["post", "url"].url,
                body: post["post", "body"].stringValue,
                removed: post["post", "removed"].boolValue,
                locked: post["post", "locked"].boolValue,
                published: {
                    return convertResponseDateToDate(responseDate: post["post", "published"].stringValue)
                }(),
                updated: post["post", "updated"].string,
                deleted: post["post", "deleted"].boolValue,
                nsfw: post["post", "nsfw"].boolValue,
                stickied: post["post", "featured_local"].boolValue,
                embedTitle: post["post", "embed_title"].string,
                embedDescription: post["post", "embed_description"].string,
                embedHTML: nil,
                thumbnailURL: post["post", "thumbnail_url"].url,
                apID: post["post", "ap_id"].stringValue,
                local: post["post", "local"].boolValue,
                postedAt: post["creator", "published"].stringValue,
                numberOfComments: post["counts", "comments"].intValue,
                score: post["counts", "score"].intValue,
                upvotes: post["counts", "upvotes"].intValue,
                downvotes: post["counts", "downvotes"].intValue,
                myVote: {
                    let parsedResponse = post["my_vote"].int
                    
                    if parsedResponse == nil
                    {
                        return MyVote.none
                    }
                    else if parsedResponse == 1
                    {
                        return MyVote.upvoted
                    }
                    else
                    {
                        return MyVote.downvoted
                    }
                }(),
                hotRank: nil,
                hotRankActive: nil,
                newestActivityTime: post["counts", "newest_comment_time"].stringValue,
                
                author: User(
                    id: post["creator", "id"].intValue,
                    name: post["creator", "name"].stringValue,
                    displayName: post["creator", "display_name"].string,
                    avatarLink: post["creator", "avatar"].url,
                    bannerLink: post["creator", "banner"].url,
                    inboxLink: post["creator", "inbox_url"].url,
                    bio: post["creator", "bio"].stringValue,
                    banned: post["creator", "banned"].boolValue,
                    actorID: post["creator", "actor_id"].url!,
                    local: post["creator", "local"].boolValue,
                    deleted: post["creator", "deleted"].boolValue,
                    admin: post["creator", "admin"].boolValue,
                    bot: post["creator", "bot_account"].boolValue,
                    onInstanceID: post["creator", "instance_id"].intValue
                ),
                
                community: Community(
                    id: post["community", "id"].intValue,
                    name: post["community", "name"].stringValue,
                    title: post["community", "title"].string,
                    description: post["community", "description"].string,
                    icon: post["community", "icon"].url,
                    banner: post["community", "banner"].url,
                    createdAt: post["community", "published"].string,
                    updatedAt: post["community", "updated"].string,
                    actorID: post["community", "actor_id"].url!,
                    local: post["community", "local"].boolValue,
                    deleted: post["community", "deleted"].boolValue,
                    nsfw: post["community", "nsfw"].boolValue
                )
            )
            
            postTracker.append(
                newPost
            )
        }
        
        return postTracker
    }
    catch let parsingError
    {
        print("Failed while parsing post response: \(parsingError)")
        throw JSONParsingError.failedToParse
    }
}
