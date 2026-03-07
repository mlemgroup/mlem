//
//  Searchable.swift
//  Mlem
//
//  Created by Sjmarf on 28/06/2024.
//

import MlemMiddleware

// swiftlint:disable function_parameter_count
protocol Searchable: Identifiable {
    static func search(
        api: ApiClient,
        query: String,
        page: Int,
        limit: Int,
        filter: ListingType,
        hostApi: ApiClient?
    ) async throws -> [Self]
}

extension Community: Searchable {
    static func search(
        api: ApiClient,
        query: String,
        page: Int,
        limit: Int,
        filter: ListingType,
        hostApi: ApiClient?
    ) async throws -> [Community] {
        try await api.searchCommunities(query: query, page: page, limit: limit, filter: filter, hostApi: hostApi)
    }
}

extension Person: Searchable {
    static func search(
        api: ApiClient,
        query: String,
        page: Int,
        limit: Int,
        filter: ListingType,
        hostApi: ApiClient? = nil
    ) async throws -> [Person] {
        try await api.searchPeople(query: query, page: page, limit: limit, filter: filter)
    }
}

extension InstanceSummary: Searchable {
    static func search(
        api _: ApiClient,
        query: String,
        page _: Int,
        limit _: Int,
        filter _: ListingType,
        hostApi: ApiClient? = nil
    ) async throws -> [InstanceSummary] {
        try await MlemStats.main.searchInstances(query: query)
    }
}

// swiftlint:enable function_parameter_count
