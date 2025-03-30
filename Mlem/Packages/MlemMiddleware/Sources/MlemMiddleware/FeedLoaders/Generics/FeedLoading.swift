//
//  FeedLoading.swift
//
//
//  Created by Eric Andrews on 2024-07-05.
//

import Foundation

public protocol FeedLoading<Item>: AnyObject {
    associatedtype Item: FeedLoadable
    
    var items: [Item] { get }
    var loadingState: LoadingState { get }
    
    func loadMoreItems() async throws
    func loadIfThreshold(_ item: Item) throws
    func refresh(clearBeforeRefresh: Bool) async throws
    func clear() async
    func changeApi(to newApi: ApiClient, context: FilterContext) async
    
    /// Adds the given item to the beginning of the items array, regardless of whether it should be filtered
    /// - Warning: when using this method with multi-feed loaders, you must call this on both the parent loader and the relevant child loader!
    func prependItem(_ newItem: Item)
}
