//
//  Searchable.swift
//  Mlem
//
//  Created by Sjmarf on 28/06/2024.
//

import MlemMiddleware

protocol Searchable: Identifiable {
    static func search(api: ApiClient, query: String, page: Int, limit: Int, filter: ApiListingType) async throws -> [Self]
}

extension Community2: Searchable {
    static func search(api: ApiClient, query: String, page: Int, limit: Int, filter: ApiListingType) async throws -> [Community2] {
        try await api.searchCommunities(query: query, page: page, limit: limit, filter: filter)
    }
}

extension Person2: Searchable {
    static func search(api: ApiClient, query: String, page: Int, limit: Int, filter: ApiListingType) async throws -> [Person2] {
        try await api.searchPeople(query: query, page: page, limit: limit, filter: filter)
    }
}

extension InstanceSummary: Searchable, Identifiable {
    var id: String { host }
    
    static func search(
        api _: ApiClient,
        query: String,
        page _: Int,
        limit _: Int,
        filter _: ApiListingType) async throws -> [InstanceSummary] {
            try await MlemStats.main.searchInstances(query: query)
        }
}
