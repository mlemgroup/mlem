//
//  TrackerProtocol.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-14.
//

import Foundation

/// Protocol for common tracker logic
protocol TrackerProtocol<Item>: ObservableObject {
    associatedtype Item: TrackerItem
    
    var items: [Item] { get }
    var loadingState: LoadingState { get }
    func loadMoreItems() async
    func loadIfThreshold(_ item: Item)
}
