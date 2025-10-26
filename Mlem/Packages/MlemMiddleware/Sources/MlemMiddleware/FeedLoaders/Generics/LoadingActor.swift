//
//  LoadingActor.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-10-27.
//

import Foundation
import os

enum LoadingError: Error {
    case noTask
}

actor LoadingActor<Item: FeedLoadable> {
    internal let log: Logger = .mlemLogger()
    
    private var done: Bool = false
    private var loadingTask: Task<Void, Error>?
    var filter: MultiFilter<Item>
  
    private var fetcher: Fetcher<Item>
    
    public init(fetcher: Fetcher<Item>, filter: MultiFilter<Item>) {
        self.fetcher = fetcher
        self.filter = filter
    }
    
    /// Cancels any ongoing loading and resets the page/cursor to 0
    func reset() async {
        loadingTask?.cancel()
        loadingTask = nil
        filter.reset()
        await fetcher.reset()
        done = false
    }
    
    /// Loads the next page of items.
    /// - Returns: on success, .success with FetchResponse containing loaded items; if another load is underway, .ignored; if the load is cancelled, .cancelled
    func load(_ callback: @escaping (LoadingResponse<Item>) async -> Void) async throws {
        guard !done else {
            log.debug("[\(Self.self)] ignoring request, finished loading")
            return
        }
        
        // if already loading something, ignore the request
        if let loadingTask {
            log.debug("[\(Self.self)] ignoring request, load underway")
            // return .ignored
            _ = try await loadingTask.result.get()
            log.debug("[\(Self.self)] preexisting load finished, returning")
            return
        }
        
        // upon completion of load, remove loading task
        defer { loadingTask = nil }
        
        loadingTask = Task<Void, Error> {
            let response = try await fetchMoreItems()
            await callback(response)
        }
        
        guard let loadingTask else {
            assertionFailure("loadingTask is nil!")
            throw LoadingError.noTask
        }
        
        _ = try await loadingTask.result.get()
        log.info("[\(Self.self)] finished loading")
    }
    
    @discardableResult
    func filterItem(_ target: Item) -> Item? {
        let filtered = filter.filter([target])
        return filtered.first
    }
    
    func activateFilter(_ target: Item.FilterType, callback: () async throws -> Void) async throws {
        loadingTask?.cancel()
        loadingTask = nil
        if filter.activate(target) {
            try await callback()
        }
    }
    
    func deactivateFilter(_ target: Item.FilterType, callback: () async throws -> Void) async throws {
        loadingTask?.cancel()
        loadingTask = nil
        if filter.deactivate(target) {
            try await callback()
        }
    }
    
    // MARK: Helpers
    
    private func fetchMoreItems() async throws -> LoadingResponse<Item> {
        var newItems: [Item] = .init()
        fetchLoop: repeat {
            let response = try await fetcher.fetch()
            
            switch response {
            case let .success(items):
                log.debug("[\(Self.self)] received success (\(items.count))")
                newItems.append(contentsOf: filter.filter(items))
            case let .done(items):
                log.debug("[\(Self.self)] received finished (\(items.count))")
                newItems.append(contentsOf: filter.filter(items))
                return .done(newItems)
            case .cancelled, .ignored:
                log.info("[\(Self.self)] load did not complete (\(response.description))")
                break fetchLoop
            }
        } while newItems.count < MiddlewareConstants.infiniteLoadThresholdOffset

        return .success(newItems)
    }
}
