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
    #warning("TODO: Improve this so it doesn't check for the string, but maybe let it get parsed first and then check if the jsonComments array is empty")
    if commentResponse.contains("{\"comments\":[]}")
    { /// If there are no comments, just return an empty array
        print("There are no comments")
        return .init()
    }
    do
    {
        let parsedJSON: JSON = try parseJSON(from: commentResponse)
        var jsonComments = parsedJSON["comments"].arrayValue
        
        if jsonComments.isEmpty
        { /// This has to be here because I'm also using this function for parsing coments that the user posted, which has a different format. If the first attempt to get the array of comments fails, try the one that's for responses for posting comments
            jsonComments = [parsedJSON["comment_view"]]
        }
        
        var allComments = jsonComments.map { $0.v2ToComment() }

        let childrenStartIndex = allComments.partition(by: { $0.parentID != nil })
        let children = allComments[childrenStartIndex...]

        var childrenByID = [Comment.ID: [Comment.ID]]()
        children.forEach
        { child in
            guard let parentID = child.parentID else
            {
                return
            }

            childrenByID[parentID] = (childrenByID[parentID] ?? []) + [child.id]
        }

        let identifiedComments = Dictionary(uniqueKeysWithValues: allComments.lazy.map { ($0.id, $0) })

        /// Recursively populates child comments by looking up IDs from `childrenByID`
        func populateChildren(_ comment: Comment) -> Comment
        {
            guard let childIDs = childrenByID[comment.id] else
            {
                return comment
            }

            var commentWithChildren = comment
            commentWithChildren.children = childIDs.compactMap
            { id in
                guard let child = identifiedComments[id] else
                {
                    return nil
                }
                return populateChildren(child)
            }
            return commentWithChildren
        }

        let parents = allComments[..<childrenStartIndex]
        return parents.map(populateChildren)
    }
    catch let parsingError
    {
        print("Failed while parsing comment JSON: \(parsingError)")
        throw JSONParsingError.failedToParse
    }
}

func parseReply(replyResponse: String, instanceLink: URL) async throws -> Comment
{
    do
    {
        let parsedJSON: JSON = try parseJSON(from: replyResponse)
        var jsonComments = parsedJSON["comments"].arrayValue
        
        if jsonComments.isEmpty
        { /// This has to be here because I'm also using this function for parsing coments that the user posted, which has a different format. If the first attempt to get the array of comments fails, try the one that's for responses for posting comments
            jsonComments = [parsedJSON["comment_view"]]
        }
        
        return jsonComments.map { $0.v2ToComment() }.first!
    }
    catch let parsingError
    {
        print("Failed while parsing comment JSON: \(parsingError)")
        throw JSONParsingError.failedToParse
    }
}

private extension JSON {
    func v2ToComment() -> Comment {
        Comment(
            id: self["comment", "id"].intValue,
            postID: self["post", "id"].intValue,
            creatorID: self["comment", "creator_id"].intValue,
            //postName: <#T##String#>,
            parentID: {
                let stringRepresentationOfPath: String = self["comment", "path"].stringValue
                let componentsOfPath = stringRepresentationOfPath.components(separatedBy: ".")
                
                print("Will try to parse path \(stringRepresentationOfPath)")
                print("Will try to parse path \(componentsOfPath)")

                if componentsOfPath.count == 2 || stringRepresentationOfPath == "0"/// If there are two elements, it'ß the root (0) and the comment itself. That means there is no parent and parentID should be nil
                {
                    return nil
                }
                else
                {
                    return Int(componentsOfPath.dropLast(1).last!)
                }
            }(),
            content: self["comment", "content"].stringValue,
            removed: self["comment", "removed"].boolValue,
            //read: self[""],
            published: {
                return convertResponseDateToDate(responseDate: self["comment", "published"].stringValue)
            }(),
            deleted: self["comment", "deleted"].boolValue,
            updated: self["comment", "updated"].string,
            apID: self["comment", "ap_id"].url!,
            local: self["comment", "local"].boolValue,
            communityID: self["community", "id"].intValue,
            communityActorID: self["community", "actor_id"].url!,
            communityLocal: self["community", "local"].boolValue,
            communityName: self["community", "name"].stringValue,
            communityIcon: self["community", "icon"].url,
            communityHideFromAll: self["community", "hidden"].boolValue,
            creatorPublished: self["creator", "published"].stringValue,
            score: self["counts", "score"].intValue,
            upvotes: self["counts", "upvotes"].intValue,
            downvotes: self["counts", "downvotes"].intValue,
            myVote: {
                let parsedResponse = self["my_vote"].int
                
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
            //hotRank: <#T##Int#>,
            //hotRankActive: <#T##Int?#>,
            saved: self["saved"].boolValue,
            author: User(
                id: self["creator", "id"].intValue,
                name: self["creator", "name"].stringValue,
                displayName: self["creator", "display_name"].string,
                avatarLink: self["creator", "avatar"].url,
                bannerLink: self["creator", "banner"].url,
                inboxLink: self["creator", "inbox_url"].url,
                bio: self["creator", "bio"].stringValue,
                banned: self["creator", "banned"].boolValue,
                actorID: self["creator", "actor_id"].url!,
                local: self["creator", "local"].boolValue,
                deleted: self["creator", "deleted"].boolValue,
                admin: self["creator", "admin"].boolValue,
                bot: self["creator", "bot_account"].boolValue,
                onInstanceID: self["creator", "instance_id"].intValue
            ),
            //subscribed: <#T##Bool?#>,
            childCount: self["counts", "child_count"].int,
            children: []
        )
    }
}
