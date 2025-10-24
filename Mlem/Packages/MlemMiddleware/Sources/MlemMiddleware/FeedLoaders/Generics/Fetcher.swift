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
    internal let log: Logger = .mlemLogger(subsystem: "MlemMiddleware")
    
    var api: ApiClient
    var pageSize: Int
    var page: Int
    private var cursor: String?
    
    init(api: ApiClient, pageSize: Int, page: Int = 0) {
        self.api = api
        self.pageSize = pageSize
        self.page = page
    }
    
    /// Helper struct bundling the response from a fetchPage or fetchCursor call
    struct FetchResponse {
        /// Items returned
        public let items: [Item]
        
        /// Cursor used to fetch this response, if applicable
        public let prevCursor: String?
        
        /// New cursor, if applicable
        public let nextCursor: String?
    }
    
    /// Fetches the next page of items
    func fetch() async throws -> LoadingResponse<Item> {
        do {
            if let cursor, page > 0 {
                log.debug("[\(Item.self) Fetcher] loading cursor \(cursor)")
                let response = try await fetchCursor(cursor)
                
                // if same cursor returned, loading is finished
                if response.nextCursor == self.cursor {
                    return .done(response.items)
                }
                
                self.cursor = response.nextCursor
                return .success(response.items)
            } else {
                page += 1
                log.debug("[\(Item.self) Fetcher] loading page \(self.page)")
                let response = try await fetchPage(page)
                
                // if nothing returned, loading is finished
                if response.items.count < pageSize {
                    log.debug("[\(Item.self) Fetcher] received undersized page (\(response.items.count)/\(self.pageSize))")
                    return .done(response.items)
                }
                cursor = response.nextCursor
                return .success(response.items)
            }
        } catch is CancellationError {
            return .cancelled
        }
    }
    
    /// Fetches the given page of items.
    /// - Parameters:
    ///   - page: page number to fetch
    /// - Returns: tuple of the requested page of items, the cursor returned by the API call (if present), and the number of items that were filtered out.
    func fetchPage(_ page: Int) async throws -> FetchResponse {
        preconditionFailure("This method must be implemented by the inheriting class")
    }
    
    /// Fetches items from the given cursor.
    /// - Parameters:
    ///   - cursor: cursor to fetch
    /// - Returns: tuple of the requested page of items, the cursor returned by the API call (if present), and the number of items that were filtered out.
    func fetchCursor(_ cursor: String) async throws -> FetchResponse {
        preconditionFailure("This method must be implemented by the inheriting class")
    }
    
    /// Resets the fetcher's page and cursor tracking. This method should only be overridden to handle abnormal pagination behavior (e.g., PersonContentFetcher); it should NOT change loading parameters such as query or sort.
    func reset() async {
        page = 0
        cursor = nil
    }
    
    func changeApi(to newApi: ApiClient, context: FilterContext) async {
        api = newApi
    }
}
