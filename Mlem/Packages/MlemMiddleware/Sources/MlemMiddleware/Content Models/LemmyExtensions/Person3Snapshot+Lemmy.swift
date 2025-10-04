//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Person3Snapshot {
    init(from userInfo: LemmyMyUserInfo) throws(ApiClientError) {
        var moderatedCommunities: [Community1Snapshot] = []
        moderatedCommunities.reserveCapacity(userInfo.moderates.count)
        
        for moderate in userInfo.moderates {
            try moderatedCommunities.append(.init(from: moderate.community))
        }
        
        self.init(
            person: try .init(from: userInfo.localUserView),
            site: nil,
            moderatedCommunities: moderatedCommunities
        )
    }
    
    init(from personDetails: LemmyGetPersonDetailsResponse) throws(ApiClientError) {
        var moderatedCommunities: [Community1Snapshot] = []
        moderatedCommunities.reserveCapacity(personDetails.moderates.count)
        
        for moderate in personDetails.moderates {
            try moderatedCommunities.append(.init(from: moderate.community))
        }

        self.init(
            person: try .init(from: personDetails.personView),
            site: try personDetails.site.map { site throws(ApiClientError) in try.init(from: site) },
            moderatedCommunities: moderatedCommunities
        )
    }
}
