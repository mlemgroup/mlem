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
    do
    {
        let parsedJSON: JSON = try parseJSON(from: commentResponse)
        let jsonComments = parsedJSON["data", "comments"].arrayValue

        let isV1 = instanceLink.absoluteString.contains("v1")
        var allComments = jsonComments.map { isV1 ? $0.v1ToComment() : $0.v2ToComment() }

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

private extension JSON {

    func v1ToComment() -> Comment {
        Comment(
            id: self["id"].intValue,
            postID: self["post_id"].intValue,
            creatorID: self["creator_id"].intValue,
            //postName: self["post_name"].stringValue,
            parentID: self["parent_id"].int,
            content: self["content"].stringValue,
            removed: self["removed"].boolValue,
            //read: self["read"].boolValue,
            published: {
                return convertResponseDateToDate(responseDate: self["published"].stringValue)
            }(),
            deleted: self["deleted"].boolValue,
            updated: self["updated"].string,
            apID: self["ap_id"].url!,
            local: self["local"].boolValue,
            communityID: self["community_id"].intValue,
            communityActorID: self["community_actor_id"].url!,
            communityLocal: self["local"].boolValue,
            communityName: self["community_name"].stringValue,
            communityIcon: self["community_icon"].url,
            communityHideFromAll: self["community_hide_from_all"].boolValue,
            //bannedFromCommunity: self["banned_from_community"].boolValue,
            creatorPublished: self["creator_published"].stringValue,
            score: self["score"].intValue,
            upvotes: self["upvotes"].intValue,
            downvotes: self["downvotes"].intValue,
            //hotRank: self["hot_rank"].intValue,
            //hotRankActive: self["hot_rank_active"].intValue,
            saved: self["saved"].boolValue,
            author: User(
                id: 0,
                name: self["creator_name"].stringValue,
                displayName: self["creator_preferred_username"].stringValue,
                avatarLink: self["creator_avatar"].url,
                bannerLink: nil,
                inboxLink: nil,
                bio: nil,
                banned: self["banned"].boolValue,
                actorID: self["creator_actor_id"].url!,
                local: self["creator_local"].boolValue,
                deleted: false,
                admin: false,
                bot: false,
                onInstanceID: 0
            ),
            childCount: nil,
            //subscribed: comment["subscribed"].boolValue,
            children: .init()
        )
    }

    func v2ToComment() -> Comment {
        Comment(
            id: self["comment", "id"].intValue,
            postID: self["post", "id"].intValue,
            creatorID: self["comment", "creator_id"].intValue,
            //postName: <#T##String#>,
            parentID: {
                let stringRepresentationOfPath: String = self["comment", "path"].stringValue
                let componentsOfPath = stringRepresentationOfPath.components(separatedBy: ".")

                if componentsOfPath.count == 2 /// If there are two elements, it'ß the root (0) and the comment itself. That means there is no parent and parentID should be nil
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
