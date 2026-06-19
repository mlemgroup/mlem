//
//  Searchable.swift
//  Mlem
//
//  Created by Sjmarf on 28/06/2024.
//

import MlemBackend
import MlemMiddleware

protocol Searchable: Identifiable {
    static func search(
        api: ApiClient,
        query: String,
        pageInfo: PageInfo,
        filter: ListingType,
        hostApi: ApiClient?
    ) async throws -> PagedResponse<Self>
}

extension Community: Searchable {
    static func search(
        api: ApiClient,
        query: String,
        pageInfo: PageInfo,
        filter: ListingType,
        hostApi: ApiClient?
    ) async throws -> PagedResponse<Community> {
        try await api.searchCommunities(query: query, pageInfo: pageInfo, filter: filter, hostApi: hostApi)
    }
}

extension Person: Searchable {
    static func search(
        api: ApiClient,
        query: String,
        pageInfo: PageInfo,
        filter: ListingType,
        hostApi: ApiClient? = nil
    ) async throws -> PagedResponse<Person> {
        try await api.searchPeople(query: query, pageInfo: pageInfo, filter: filter)
    }
}

extension InstanceSummary: Searchable {
    static func search(
        api _: ApiClient,
        query: String,
        pageInfo _: PageInfo,
        filter _: ListingType,
        hostApi: ApiClient? = nil
    ) async throws -> PagedResponse<InstanceSummary> {
        let items = try await MlemStats.main.searchInstances(query: query)
        return .init(items: items, nextLocation: .end)
    }
}
