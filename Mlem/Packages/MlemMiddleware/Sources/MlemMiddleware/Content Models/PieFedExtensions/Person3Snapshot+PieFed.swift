//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Person3Snapshot {
    init(from userInfo: PieFedMyUserInfo) throws(ApiClientError) {
        var moderatedCommunities: [Community1Snapshot] = []
        moderatedCommunities.reserveCapacity(userInfo.moderates.count)
        
        for moderate in userInfo.moderates {
            try moderatedCommunities.append(.init(from: moderate.community))
        }

        try self.init(
            person: .init(from: userInfo.localUserView),
            site: nil,
            moderatedCommunities: moderatedCommunities
        )
    }
    
    init(from personDetails: PieFedGetUserResponse) throws(ApiClientError) {
        var moderatedCommunities: [Community1Snapshot] = []
        moderatedCommunities.reserveCapacity(personDetails.moderates.count)
        
        for moderate in personDetails.moderates {
            try moderatedCommunities.append(.init(from: moderate.community))
        }
        
        try self.init(
            person: .init(from: personDetails.personView, allPropertiesPresent: true),
            site: personDetails.site.map { site throws(ApiClientError) in try .init(from: site) },
            moderatedCommunities: moderatedCommunities
        )
    }
}
