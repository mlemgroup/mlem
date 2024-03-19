//
//  ModlogTrackerProtocol.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-14.
//

import Foundation

/// Protocol to allow modlog tracker and its children to be treated identically
protocol ModlogTrackerProtocol {
    var items: [ModlogEntry] { get }
    var loadingState: LoadingState { get }
    func loadMoreItems() async
    func loadIfThreshold(_ item: ModlogEntry)
}
