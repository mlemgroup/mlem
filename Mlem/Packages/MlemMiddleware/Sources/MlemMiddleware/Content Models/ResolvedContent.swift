//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-07.
//

import Foundation

public enum ResolvedContent {
    case comment(Comment2Snapshot)
    case post(Post2Snapshot)
    case community(Community2Snapshot)
    case person(Person2Snapshot)
    
    init(from response: ApiResolveObjectResponse) throws {
        if let comment = response.comment {
            self = try .comment(.init(from: comment))
        } else if let post = response.post {
            self = try .post(.init(from: post))
        } else if let community = response.community {
            self = try .community(.init(from: community))
        } else if let person = response.person {
            self = try .person(.init(from: person))
        } else {
            throw ApiClientError.noEntityFound
        }
    }
}
