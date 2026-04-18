//
//  CommunityStub.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Foundation

public struct CommunityStub:  Hashable {
    public var api: ApiClient
    public let url: URL
    
    public init(api: ApiClient, url: URL) {
        self.api = api
        self.url = url
    }
    
    public func asLocal() -> Self {
        .init(api: .getApiClient(url: url.removingPathComponents(), username: nil), url: url)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    
    public static func == (lhs: CommunityStub, rhs: CommunityStub) -> Bool {
        lhs.url == rhs.url
    }
    
    public func getCommunity() async throws -> Community {
        try await api.getCommunity(url: url)
    }
}

// Resolvable conformance
public extension CommunityStub {
    var resolvableUrl: URL { url }
    
    @inlinable
    var allResolvableUrls: [URL] { [resolvableUrl] }
}
