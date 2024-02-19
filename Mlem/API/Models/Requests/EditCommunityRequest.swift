//
//  EditCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct EditCommunityRequest: APIPutRequest {
    typealias Body = APIEditCommunity
    typealias Response = APICommunityResponse

    let path = "/community"
    let body: Body?

    init(
        communityId: Int,
        title: String?,
        description: String?,
        icon: String?,
        banner: String?,
        nsfw: Bool?,
        postingRestrictedToMods: Bool?,
        discussionLanguages: [Int]?
    ) {
        self.body = .init(
            community_id: communityId,
            title: title,
            description: description,
            icon: icon,
            banner: banner,
            nsfw: nsfw,
            posting_restricted_to_mods: postingRestrictedToMods,
            discussion_languages: discussionLanguages
        )
    }
}
