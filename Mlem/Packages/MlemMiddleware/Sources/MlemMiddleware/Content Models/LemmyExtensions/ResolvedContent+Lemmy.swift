//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension ResolvedContent {
    init(from response: LemmyResolveObjectResponseUnion) throws(ApiClientError) {
        switch response {
        case let .lemmyResolveObjectResponse(value):
            try self.init(from: value)
        case let .lemmySearchResponse(value):
            try self.init(from: value)
        }
    }
    
    init(from response: LemmyResolveObjectResponse) throws(ApiClientError) {
        if let comment = response.comment {
            self = try .comment(.init(from: comment))
        } else if let post = response.post {
            self = try .post(.init(from: post))
        } else if let community = response.community {
            self = try .community(.init(from: community))
        } else if let person = response.person {
            self = try .person(.init(from: person))
        } else {
            throw .noEntityFound
        }
    }
    
    init(from response: LemmySearchResponse) throws(ApiClientError) {
        // This initializer is only used in 1.0.0 onwards, so we only need
        // to consider the `results` array and not the other arrays (which
        // are only used prior to 1.0.0)
        guard let results = response.results else {
            assertionFailure()
            throw .noEntityFound
        }
        
        guard let result = results.first else {
            throw .noEntityFound
        }
        
        switch result {
        case let .comment(comment):
            self = try .comment(.init(from: comment))
        case let .community(community):
            self = try .community(.init(from: community))
        case .multiCommunity:
            throw .featureUnsupported
        case let .person(person):
            self = try .person(.init(from: person))
        case let .post(post):
            self = try .post(.init(from: post))
        }
    }
}
