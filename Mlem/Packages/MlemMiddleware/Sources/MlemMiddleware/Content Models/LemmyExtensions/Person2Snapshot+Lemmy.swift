//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Person2Snapshot {
    init(from person: LemmyPersonView) throws(ApiClientError) {
        guard let postCount = person.person.postCount ?? person.counts?.postCount else {
            throw .responseMissingRequiredData("LemmyPersonView postCount")
        }
        
        guard let commentCount = person.person.commentCount ?? person.counts?.commentCount else {
            throw .responseMissingRequiredData("LemmyPersonView commentCount")
        }

        try self.init(
            person: .init(from: person.person),
            isAdmin: person.isAdmin,
            postCount: postCount,
            commentCount: commentCount
        )
    }
    
    init(from localUser: LemmyLocalUserView) throws(ApiClientError) {
        guard let postCount = localUser.person.postCount ?? localUser.counts?.postCount else {
            throw .responseMissingRequiredData("LemmyLocalUserView postCount")
        }
        
        guard let commentCount = localUser.person.commentCount ?? localUser.counts?.commentCount else {
            throw .responseMissingRequiredData("LemmyLocalUserView commentCount")
        }

        try self.init(
            person: .init(from: localUser.person),
            isAdmin: localUser.localUser.admin,
            postCount: postCount,
            commentCount: commentCount
        )
    }
}
