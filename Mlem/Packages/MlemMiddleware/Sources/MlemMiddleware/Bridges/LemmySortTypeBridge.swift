//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-22.
//

import Foundation
import Rest
import URLEncoder

// The `LemmySearch.sort` property uses `LemmySortType` pre-0.20 and
// uses `LemmySearchSortType` post-0.20, even when interacting using the v3 api.
// The type of that property is manually overriden with this type, which
// can then be converted into either of those two types.

public typealias ApiBridgeable = Codable & Hashable & RawRepresentable<String> & Sendable

public enum ApiBridge<OldType: ApiBridgeable, NewType: ApiBridgeable>: Codable, Hashable, Sendable {
    case old(OldType)
    case new(NewType)
    
    public typealias RawValue = String
    
    var value: any ApiBridgeable {
        switch self {
        case let .old(old): old
        case let .new(new): new
        }
    }
    
    public static func oldOrUnsupported(_ value: OldType?) throws(ApiClientError) -> Self {
        if let value {
            return .old(value)
        } else {
            throw .featureUnsupported
        }
    }

    public static func newOrUnsupported(_ value: NewType?) throws(ApiClientError) -> Self {
        if let value {
            return .new(value)
        } else {
            throw .featureUnsupported
        }
    }
}

public extension ApiBridge {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let new = try? container.decode(NewType.self) {
            self = .new(new)
            return
        }
        if let old = try? container.decode(OldType.self) {
            self = .old(old)
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unsupported value type"))
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value.rawValue)
    }
}

public typealias LemmySearchSortTypeBridge = ApiBridge<LemmySortType, LemmySearchSortType>
public typealias LemmyPostSortTypeBridge = ApiBridge<LemmySortType, LemmyPostSortType>
public typealias LemmyCommunitySortTypeBridge = ApiBridge<LemmySortType, LemmyCommunitySortType>
