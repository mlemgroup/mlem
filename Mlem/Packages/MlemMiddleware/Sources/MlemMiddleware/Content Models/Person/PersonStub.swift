//
//  Account.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation
import Observation

public struct PersonStub: PersonStubProviding, Hashable {
    public static let tierNumber: Int = 0
    public var api: ApiClient
    public let url: URL
    
    public init(api: ApiClient, url: URL) {
        self.api = api
        self.url = url
    }
    
    public func asLocal() -> Self {
        .init(api: .getApiClient(url: url, username: nil), url: url)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    
    public static func == (lhs: PersonStub, rhs: PersonStub) -> Bool {
        lhs.url == rhs.url
    }
    
    public func upgrade() async throws -> any Person {
        try await api.getPerson(url: url) as Person2
    }
}

// Resolvable conformance
public extension PersonStub {
    var resolvableUrl: URL { url }
    
    @inlinable
    var allResolvableUrls: [URL] { [resolvableUrl] }
}
