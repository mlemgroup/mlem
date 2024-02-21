//
//  EditCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct EditCommunityRequest: ApiPutRequest {
    typealias Body = ApiEditCommunity
    typealias Response = ApiCommunityResponse

    let path = "/community"
    let body: Body?

    init(
        communityId: Int,
        title: String?,
        description: String?,
        icon: URL?,
        banner: URL?,
        nsfw: Bool?,
        postingRestrictedToMods: Bool?,
        discussionLanguages: [Int]?
    ) {
        self.body = .init(
            communityId: communityId,
            title: title,
            description: description,
            icon: icon,
            banner: banner,
            nsfw: nsfw,
            postingRestrictedToMods: postingRestrictedToMods,
            discussionLanguages: discussionLanguages
        )
    }
}
