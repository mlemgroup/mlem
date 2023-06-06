//
//  User Parser.swift
//  Mlem
//
//  Created by David Bureš on 06.05.2023.
//

import Foundation
import SwiftyJSON


func parseUser(userResponse: String) async throws -> User
{
    do
    {
        let parsedJSON: JSON = try parseJSON(from: userResponse)
        
        return User(
            id: parsedJSON["person_view", "person", "id"].intValue,
            name: parsedJSON["person_view", "person", "name"].stringValue,
            displayName: parsedJSON["person_view", "person", "display_name"].string,
            avatarLink: parsedJSON["person_view", "person", "avatar"].url,
            bannerLink: parsedJSON["person_view", "person", "banner"].url,
            inboxLink: parsedJSON["person_view", "person", "inbox_url"].url,
            bio: parsedJSON["person_view", "person", "bio"].string,
            banned: parsedJSON["person_view", "person", "banned"].boolValue,
            actorID: parsedJSON["person_view", "person", "actor_id"].url!,
            local: parsedJSON["person_view", "person", "local"].boolValue,
            deleted: parsedJSON["person_view", "person", "deleted"].boolValue,
            admin: parsedJSON["person_view", "person", "admin"].boolValue,
            bot: parsedJSON["person_view", "person", "bot_account"].boolValue,
            onInstanceID: parsedJSON["person_view", "person", "instance_id"].intValue,
            details: UserDetails(
                commentScore: parsedJSON["person_view", "counts", "comment_score"].intValue,
                postScore: parsedJSON["person_view", "counts", "post_score"].intValue,
                commentNumber: parsedJSON["person_view", "counts", "comment_count"].intValue,
                postNumber: parsedJSON["person_view", "counts", "post_count"].intValue
            )
        )
    }
    catch let parsingError
    {
        print("Failed while parsing user JSON: \(parsingError)")
        throw JSONParsingError.failedToParse
    }
}

