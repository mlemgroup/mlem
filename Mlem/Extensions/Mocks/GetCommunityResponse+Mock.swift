//
//  GetCommunityResponse+Mock.swift
//  Mlem
//
//  Created by mormaer on 20/08/2023.
//
//

import Foundation

extension GetCommunityResponse {
    static func mock(
        communityView: APICommunityView = .mock(),
        site: APISite? = nil,
        moderators: [APICommunityModeratorView] = [],
        discussionLanguages: [Int] = [],
        defaultPostLanguage: Int? = nil
    ) -> GetCommunityResponse {
        .init(
            communityView: communityView,
            site: site,
            moderators: moderators,
            discussionLanguages: discussionLanguages,
            defaultPostLanguage: defaultPostLanguage
        )
    }
}
