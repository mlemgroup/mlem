//
//  FeedLoadable.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//

import Foundation

public protocol FeedLoadable: Filterable, Equatable {
    associatedtype FilterType
    var api: ApiClient { get }
    
    func sortVal(sortType: FeedLoaderSort.SortType) -> FeedLoaderSort
}
