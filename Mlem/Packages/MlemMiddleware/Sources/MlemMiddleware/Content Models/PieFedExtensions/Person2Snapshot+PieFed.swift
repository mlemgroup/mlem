//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Person2Snapshot {
    init(from person: PieFedPersonView, allPropertiesPresent: Bool = false) throws(ApiClientError) {
        self.person = try .init(from: person.person, allPropertiesPresent: allPropertiesPresent)
        self.isAdmin = person.isAdmin
        self.postCount = person.counts.postCount
        self.commentCount = person.counts.commentCount
    }
}
