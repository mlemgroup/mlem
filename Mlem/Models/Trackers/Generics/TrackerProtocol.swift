//
//  TrackerProtocol.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-14.
//

import Foundation

/// Protocol to allow modlog tracker and its children to be treated identically
protocol TrackerProtocol<Item> {
    associatedtype Item: TrackerItem
    
    var items: [Item] { get }
    var loadingState: LoadingState { get }
    func loadMoreItems() async
    func loadIfThreshold(_ item: Item)
}
