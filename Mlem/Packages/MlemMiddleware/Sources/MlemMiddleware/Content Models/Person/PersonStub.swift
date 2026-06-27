//
//  Account.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

public struct PersonStub: Hashable {
    public var api: ApiClient

    private enum Reference: Hashable {
        case url(URL)
        case handle(PersonHandle)

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

    public static func == (lhs: PersonStub, rhs: PersonStub) -> Bool {
        lhs.reference == rhs.reference
    }

    public func getPerson() async throws -> Person {
        switch reference {
        case let .url(url):
            try await api.getPerson(url: url)
        case let .handle(handle):
            try await api.getPerson(handle: handle)
        }
    }
}

public extension PersonStub {
    init(api: ApiClient, url: URL) {
        self.api = api
        self.reference = .url(url)
    }

    init(api: ApiClient, handle: PersonHandle) {
        self.api = api
        self.reference = .handle(handle)
    }
}
