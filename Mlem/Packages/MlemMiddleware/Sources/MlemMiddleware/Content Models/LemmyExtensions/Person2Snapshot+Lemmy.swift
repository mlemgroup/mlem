//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Person2Snapshot {
    init(from person: LemmyPersonView) throws(ApiClientError) {
        self.person = try .init(from: person.person)
        
        self.isAdmin = person.isAdmin
        
        if let postCount = person.person.postCount ?? person.counts?.postCount {
            self.postCount = postCount
        } else {
            throw .responseMissingRequiredData("LemmyPersonView postCount")
        }
        
        if let commentCount = person.person.commentCount ?? person.counts?.commentCount {
            self.commentCount = commentCount
        } else {
            throw .responseMissingRequiredData("LemmyPersonView commentCount")
        }
    }
    
    init(from localUser: LemmyLocalUserView) throws(ApiClientError) {
        self.person = try .init(from: localUser.person)
        self.isAdmin = localUser.localUser.admin
        
        if let postCount = localUser.person.postCount ?? localUser.counts?.postCount {
            self.postCount = postCount
        } else {
            throw .responseMissingRequiredData("LemmyLocalUserView postCount")
        }
        
        if let commentCount = localUser.person.commentCount ?? localUser.counts?.commentCount {
            self.commentCount = commentCount
        } else {
            throw .responseMissingRequiredData("LemmyLocalUserView commentCount")
        }
    }
}
