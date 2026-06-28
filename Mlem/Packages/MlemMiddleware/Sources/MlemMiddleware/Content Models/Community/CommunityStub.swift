//
//  CommunityStub.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Foundation

public struct CommunityStub: Hashable {
    public var api: ApiClient

    private enum Reference: Hashable {
        case url(URL)
        case handle(CommunityHandle)

        var baseUrl: URL {
            switch self {
            case let .url(url): url.removingPathComponents()
            case let .handle(handle): handle.baseUrl()
            }
        }
    }

    private let reference: Reference
    
    public func asLocal() -> Self {
        .init(
            api: .getApiClient(url: reference.baseUrl, username: nil),
            reference: reference
        )
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(reference)
    }
    
    public static func == (lhs: CommunityStub, rhs: CommunityStub) -> Bool {
        lhs.reference == rhs.reference
    }
    
    public func getCommunity() async throws -> Community {
        switch reference {
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
        self.reference = .url(url)
    }

    init(api: ApiClient, handle: CommunityHandle) {
        self.api = api
        self.reference = .handle(handle)
    }
}
