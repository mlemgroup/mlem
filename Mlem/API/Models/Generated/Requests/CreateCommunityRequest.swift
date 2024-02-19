//
//  CreateCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct CreateCommunityRequest: APIPostRequest {
    typealias Body = APICreateCommunity
    typealias Response = APICommunityResponse

    let path = "/community"
    let body: Body?

    init(
        name: String,
        title: String,
        description: String?,
        icon: URL?,
        banner: URL?,
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
