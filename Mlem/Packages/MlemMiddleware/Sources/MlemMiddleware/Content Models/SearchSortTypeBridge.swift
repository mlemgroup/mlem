//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-22.
//

import Foundation
import Rest

// The `LemmySearch.sort` property uses `LemmySortType` pre-0.20 and
// uses `LemmySearchSortType` post-0.20, even when interacting using the v3 api.
// The type of that property is manually overriden with this type, which
// can then be converted into either of those two types.

public struct SearchSortTypeBridge: Codable, Hashable, Sendable, URLQueryItemEncodable {
    public typealias RawValue = String
    
    let oldSortType: LemmySortType?
    let newSortType: LemmySearchSortType?
    
    public init(oldSortType: LemmySortType?, newSortType: LemmySearchSortType?) {
        self.oldSortType = oldSortType
        self.newSortType = newSortType
    }
}

public extension SearchSortTypeBridge {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.oldSortType = try? container.decode(LemmySortType.self)
        self.newSortType = try? container.decode(LemmySearchSortType.self)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(encodeInQueryItemFormat())
    }
    
    func encodeInQueryItemFormat() -> String? {
        if let oldSortType {
            return oldSortType.rawValue
        } else if let newSortType {
            return newSortType.rawValue
        } else {
            return nil
        }
    }
}
