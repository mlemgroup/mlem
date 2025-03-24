//
//  ModlogEntry.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-23.
//

import Foundation

public struct ModlogEntry {
    public let api: ApiClient
    public let created: Date
    public let moderator: Person1?
    public let moderatorId: Int
    public let type: ModlogEntryType
}

extension ModlogEntry: FeedLoadable {
    public typealias FilterType = ModlogEntryFilterType
    
    public func sortVal(sortType: FeedLoaderSort.SortType) -> FeedLoaderSort {
        switch sortType {
        case .new:
            return .new(created)
        }
    }
    
    public static func == (lhs: ModlogEntry, rhs: ModlogEntry) -> Bool {
        lhs.created == rhs.created && lhs.type == rhs.type
    }
}
