//
//  Searchable.swift
//  Mlem
//
//  Created by Sjmarf on 28/06/2024.
//

import MlemMiddleware

protocol Searchable: Identifiable {
    static func search(api: ApiClient, query: String, page: Int, limit: Int) async throws -> [Self]
}

extension Community2: Searchable {
    static func search(api: ApiClient, query: String, page: Int, limit: Int) async throws -> [Community2] {
        try await api.searchCommunities(query: query, page: page, limit: limit)
    }
}

extension Person2: Searchable {
    static func search(api: ApiClient, query: String, page: Int, limit: Int) async throws -> [Person2] {
        try await api.searchPeople(query: query, page: page, limit: limit)
    }
}
