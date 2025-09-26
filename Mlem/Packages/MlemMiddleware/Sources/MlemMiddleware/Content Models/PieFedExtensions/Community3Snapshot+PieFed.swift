//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Community3Snapshot {
    init(from community: PieFedGetCommunityResponse) throws(ApiClientError) {
        var moderators = [Person1Snapshot]()
        for moderator in community.moderators {
            try moderators.append(.init(from: moderator.moderator))
        }

        self.init(
            community: try .init(from: community.communityView, allPropertiesPresent: true),
            instance: try community.site.map {site throws(ApiClientError) in
                try .init(from: site)
            },
            moderators: moderators,
            discussionLanguageIds: .init(community.discussionLanguages)
        )
    }
}
