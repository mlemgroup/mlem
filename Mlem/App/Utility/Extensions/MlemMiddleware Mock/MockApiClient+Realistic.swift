//
//  MockApiClient+Realistic.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-23.
//

import Foundation
import MlemMiddleware

extension MockApiClient {
    static let realistic: MockApiClient = {
        let client = MockApiClient()
        client.posts = PostMockType.Realistic.allCases.map { Post2.mock(.realistic($0), api: client) }
        client.communities = CommunityMockType.Realistic.allCases.map { Community2.mock(.realistic($0), api: client) }
        client.people = PersonMockType.Realistic.allCases.map { Person2.mock(.realistic($0), api: client) }
        return client
    }()
}
