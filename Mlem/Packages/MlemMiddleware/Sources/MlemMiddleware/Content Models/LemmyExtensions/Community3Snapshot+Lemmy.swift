//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Community3Snapshot {
    init(from community: LemmyGetCommunityResponse) throws(ApiClientError) {
        let instance: Instance1Snapshot?
        if let site = community.site {
            instance = try .init(from: site)
        } else {
            instance = nil
        }
        
        var moderators = [Person1Snapshot]()
        for moderator in community.moderators {
            try moderators.append(.init(from: moderator.moderator))
        }

        try self.init(
            community: .init(from: community.communityView),
            instance: instance,
            moderators: moderators,
            discussionLanguageIds: .init(community.discussionLanguages)
        )
    }
}
