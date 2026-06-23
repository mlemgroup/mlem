//
//  CommunityStub.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Foundation

public struct CommunityStub: Hashable {
    public var api: ApiClient

    private enum Content: Hashable {
        case url(URL)
        case handle(CommunityHandle)

        var baseUrl: URL {
            switch self {
            case let .url(url): url.removingPathComponents()
            case let .handle(handle): handle.baseUrl()
            }
        }
    }

    private let content: Content
    
    public func asLocal() -> Self {
        .init(
            api: .getApiClient(url: content.baseUrl, username: nil),
            content: content
        )
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(content)
    }
    
    public static func == (lhs: CommunityStub, rhs: CommunityStub) -> Bool {
        lhs.content == rhs.content
    }
    
    public func getCommunity() async throws -> Community {
        switch content {
        case let .url(url):
            try await api.getCommunity(url: url)
        case let .handle(handle):
            try await api.getCommunity(handle: handle)
        }
    }
}

public extension CommunityStub {
    init(api: ApiClient, url: URL) {
        self.api = api
        self.content = .url(url)
    }

    init(api: ApiClient, handle: CommunityHandle) {
        self.api = api
        self.content = .handle(handle)
    }
}
