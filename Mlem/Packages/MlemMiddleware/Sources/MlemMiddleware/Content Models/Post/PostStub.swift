//
//  PostStub.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

public struct PostStub: PostStubProviding, Hashable {
    public static let tierNumber: Int = 0
    public var api: ApiClient
    public var url: URL
    
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
    
    public static func == (lhs: PostStub, rhs: PostStub) -> Bool {
        lhs.url == rhs.url
    }
    
    public func upgrade() async throws -> any Post {
        try await api.getPost(url: resolvableUrl)
    }
}

// Resolvable conformance
public extension PostStub {
    var resolvableUrl: URL { url }
    
    @inlinable
    var allResolvableUrls: [URL] { [resolvableUrl] }
}
