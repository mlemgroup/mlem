//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Community3Snapshot {
    init(from community: PieFedGetCommunityResponse) throws(ApiClientError) {
        self.community = try .init(from: community.communityView, allPropertiesPresent: true)
        if let site = community.site {
            self.instance = try .init(from: site)
        } else {
            self.instance = nil
        }
        
        var moderators = [Person1Snapshot]()
        for moderator in community.moderators {
            try moderators.append(.init(from: moderator.moderator))
        }
        
        self.moderators = moderators
        self.discussionLanguageIds = .init(community.discussionLanguages)
    }
}
