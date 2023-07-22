// 
//  FeedItemProviding.swift
//  Mlem
//
//  Created by mormaer on 28/06/2023.
//  
//

import Foundation

/// A protocol describing an object which can provide `FeedTrackerItem`s
protocol FeedTrackerItemProviding {
    associatedtype Item: FeedTrackerItem
    var items: [Item] { get }
}

/// A protocol describing an instance that can provide it's published date
protocol PublishedDateProviding {
    var published: Date { get }
}

/// A protocol describing an item that can be understood by a `FeedTracker`
protocol FeedTrackerItem: Decodable, PublishedDateProviding {
    associatedtype UniqueIdentifier: Hashable
    var uniqueIdentifier: UniqueIdentifier { get }
}
