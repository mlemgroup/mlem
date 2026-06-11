//
//  Fetcher.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-11-17.
//

import Observation
import os

enum LoadingResponse<Item: FeedLoadable> {
    /// Indicates a successful load with more items available to fetch
    case success([Item])
    
    /// Indicates a successful load with no more items available to fetch
    case done([Item])
    
    /// Indicates the load was ignored due to an existing ongoing load
    case ignored
    
    /// Indicates the load was cancelled
    case cancelled
    
    var description: String {
        switch self {
        case let .success(items): "success (\(items.count))"
        case let .done(items): "done (\(items.count))"
        case .ignored: "ignored"
        case .cancelled: "cancelled"
        }
    }
}

@Observable
public class Fetcher<Item: FeedLoadable> {
    let log: Logger = .mlemLogger()
    
    var api: ApiClient
    var pageSize: Int
    private var location: PageLocation = .start
    
    init(api: ApiClient, pageSize: Int) {
        self.api = api
        self.pageSize = pageSize
    }
    
    /// Fetches the next page of items
    func fetch() async throws -> LoadingResponse<Item> {
        guard let cursor = self.location.cursor else { return .done([]) }
        log.debug("[\(Item.self) Fetcher] loading cursor \(cursor)")

        let response: PagedResponse<Item>
        do {
             response = try await fetchContent(cursor)
        } catch is CancellationError {
            return .cancelled
        }

        self.location = response.nextLocation

        if response.nextLocation == .end {
            return .done(response.items)
        } else {
            return .success(response.items)
        }
    }
    
    func fetchContent(_ cursor: PageCursor) async throws -> PagedResponse<Item> {
        preconditionFailure("This method must be implemented by the inheriting class")
    }
    
    /// Resets the fetcher's page and cursor tracking. This method should only be overridden to handle abnormal pagination behavior (e.g., SingleSourceMixedFetcher); it should NOT change loading parameters such as query or sort.
    func reset() async {
        location = .start
    }
    
    func changeApi(to newApi: ApiClient, context: FilterContext) async {
        api = newApi
    }
}
