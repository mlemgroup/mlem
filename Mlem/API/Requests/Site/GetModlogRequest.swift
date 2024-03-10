//
//  GetModlogRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

struct GetModlogRequest: APIGetRequest {
    typealias Response = APIGetModlogResponse
    
    let instanceURL: URL
    let path = "modlog"
    let queryItems: [URLQueryItem]
    
    init(
        session: APISession,
        modPersonId: Int?,
        communityId: Int?,
        page: Int?,
        limit: Int?,
        type_: APIModlogActionType?,
        otherPersonId: Int?
    ) throws {
        self.instanceURL = try session.instanceUrl
        
        var queryItems: [URLQueryItem] = [
            .init(name: "mod_person_id", value: modPersonId.map(String.init)),
            .init(name: "community_id", value: communityId.map(String.init)),
            .init(name: "page", value: page.map(String.init)),
            .init(name: "limit", value: limit.map(String.init)),
            .init(name: "type_", value: type_?.rawValue),
            .init(name: "other_person_id", value: otherPersonId.map(String.init))
        ]
        if let token = try? session.token {
            queryItems.append(
                .init(name: "auth", value: token)
            )
        }
        self.queryItems = queryItems
    }
}

struct APIGetModlogResponse: Decodable {
    let removed_posts: [APIModRemovePostView]
    let locked_posts: [APIModLockPostView]
    let featured_posts: [APIModFeaturePostView]
    let removed_comments: [APIModRemoveCommentView]
    let removed_communities: [APIModRemoveCommunityView]
    let banned_from_community: [APIModBanFromCommunityView]
    let banned: [APIModBanView]
    let added_to_community: [APIModAddCommunityView]
    let transferred_to_community: [APIModTransferCommunityView]
    let added: [APIModAddView]
    let admin_purged_persons: [APIAdminPurgePersonView]
    let admin_purged_communities: [APIAdminPurgeCommunityView]
    let admin_purged_posts: [APIAdminPurgePostView]
    let admin_purged_comments: [APIAdminPurgeCommentView]
    let hidden_communities: [APIModHideCommunityView]
}
