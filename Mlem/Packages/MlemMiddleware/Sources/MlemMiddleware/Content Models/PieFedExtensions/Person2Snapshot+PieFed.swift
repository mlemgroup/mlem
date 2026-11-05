//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Person2Snapshot {
    init(from person: PieFedPersonView, noteProvided: Bool = true) throws(ApiClientError) {
        try self.init(
            person: .init(from: person.person, descriptionAndBannerProvided: true, noteProvided: noteProvided),
            isAdmin: person.isAdmin,
            postCount: person.counts.postCount,
            commentCount: person.counts.commentCount
        )
    }

    init(from localUser: PieFedLocalUserView) throws(ApiClientError) {
        try self.init(
            person: .init(from: localUser.person, descriptionAndBannerProvided: true),
            isAdmin: false,
            postCount: localUser.counts.postCount,
            commentCount: localUser.counts.commentCount
        )
    }
}
