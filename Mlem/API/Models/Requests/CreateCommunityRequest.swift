//
//  CreateCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct CreateCommunityRequest: APIPostRequest {
    typealias Body = APICreateCommunity
    typealias Response = APICommunityResponse

    let path = "/community"
    let body: Body?

    init(
        name: String,
        title: String,
        description: String?,
        icon: String?,
        banner: String?,
        nsfw: Bool?,
        postingRestrictedToMods: Bool?,
        discussionLanguages: [Int]?
    ) {
        self.body = .init(
            name: name,
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
