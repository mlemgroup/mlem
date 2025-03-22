//
//  CommentStub.swift
//
//
//  Created by Sjmarf on 24/06/2024.
//

import Foundation

public struct CommentStub: CommentStubProviding, Hashable {
    public static let tierNumber: Int = 0
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
    
    public static func == (lhs: CommentStub, rhs: CommentStub) -> Bool {
        lhs.url == rhs.url
    }
    
    public func upgrade() async throws -> any Comment {
        try await api.getComment(url: resolvableUrl)
    }
}

// Resolvable conformance
public extension CommentStub {
    var resolvableUrl: URL { url }
    
    @inlinable
    var allResolvableUrls: [URL] { [resolvableUrl] }
}
