//
//  Community Details Parser.swift
//  Mlem
//
//  Created by David Bureš on 09.05.2023.
//

import Foundation
import SwiftyJSON

func parseCommunityDetails(response: String, instanceLink: URL) async throws -> CommunityDetails
{
    do
    {
        let parsedJSON: JSON = try parseJSON(from: response)
        
        var moderatorTracker: [User] = .init()
        
        let moderatorArray = parsedJSON["data", "moderators"].arrayValue
        
        if instanceLink.absoluteString.contains("v1")
        {
            print("Older API version")
            
            for moderator in moderatorArray
            {
                let newModerator: User = User(
                    id: moderator["id"].intValue,
                    name: moderator["user_name"].stringValue,
                    displayName: moderator["user_preferred_username"].string,
                    avatarLink: moderator["avatar"].url,
                    bannerLink: nil,
                    inboxLink: nil,
                    bio: nil,
                    banned: false,
                    actorID: moderator["user_actor_id"].url!,
                    local: moderator["user_local"].boolValue,
                    deleted: false,
                    admin: false,
                    bot: false,
                    onInstanceID: 0
                )
                
                moderatorTracker.append(newModerator)
            }
            
            let parsedDetails: CommunityDetails = CommunityDetails(
                numberOfSubscribers: parsedJSON["data", "community", "number_of_subscribers"].intValue,
                numberOfPosts: parsedJSON["data", "community", "number_of_posts"].intValue,
                numberOfActiveUsersOverall: nil,
                numberOfUsersOnline: parsedJSON["data", "online"].intValue,
                moderators: moderatorTracker
            )
            
            return parsedDetails
        }
        else
        {
            print("Newer API version")
            
            for moderator in moderatorArray
            {
                let newModerator: User = User(
                    id: moderator["moderator", "id"].intValue,
                    name: moderator["moderator", "name"].stringValue,
                    displayName: moderator["moderator", "display_name"].string,
                    avatarLink: moderator["moderator", "avatar"].url,
                    bannerLink: moderator["moderator", "banner"].url,
                    inboxLink: moderator["moderator", "inbox_url"].url,
                    bio: moderator["moderator", "bio"].string,
                    banned: moderator["moderator", "banned"].boolValue,
                    actorID: moderator["moderator", "actor_id"].url!,
                    local: moderator["moderator", "local"].boolValue,
                    deleted: moderator["moderator", "deleted"].boolValue,
                    admin: moderator["moderator", "admin"].boolValue,
                    bot: moderator["moderator", "bot_account"].boolValue,
                    onInstanceID: moderator["moderator", "instance_id"].intValue
                )
                
                moderatorTracker.append(
                    newModerator
                )
            }
            
            let parsedDetails: CommunityDetails = CommunityDetails(
                numberOfSubscribers: parsedJSON["data", "community_view", "counts", "subscribers"].intValue,
                numberOfPosts: parsedJSON["data", "community_view", "counts", "posts"].intValue,
                numberOfActiveUsersOverall: parsedJSON["data", "community_view", "counts", "users_active_half_year"].intValue,
                numberOfUsersOnline: parsedJSON["data", "online"].intValue,
                moderators: moderatorTracker
            )
            
            return parsedDetails
        }
        
    }
    catch let parsingError
    {
        print("Failed while parsing comment JSON: \(parsingError)")
        throw JSONParsingError.failedToParse
    }
}
