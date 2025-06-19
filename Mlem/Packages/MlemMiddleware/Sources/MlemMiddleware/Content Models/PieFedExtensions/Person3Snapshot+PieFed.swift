//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Person3Snapshot {
    init(from personDetails: PieFedGetPersonDetailsResponse) throws(ApiClientError) {
        self.person = try .init(from: personDetails.personView)
        
        if let site = personDetails.site {
            self.site = try .init(from: site)
        } else {
            self.site = nil
        }
        
        var moderatedCommunities: [Community1Snapshot] = []
        moderatedCommunities.reserveCapacity(personDetails.moderates.count)
        
        for moderate in personDetails.moderates {
            try moderatedCommunities.append(.init(from: moderate.community))
        }
        
        self.moderatedCommunities = moderatedCommunities
    }
}
