//
//  SettingsCommentSortType.swift
//  Mlem
//
//  Created by Sjmarf on 2026-09-10.
//

import Foundation
import MlemMiddleware

enum SettingsCommentSortType: Codable {
    case hot
    case new
    case old
    case controversial

    case top(SettingsSortTimeRange)

    enum CodingKeys: CodingKey {
        case hot, new, old, controversial, top
    }

    init(from decoder: any Decoder) throws {
        // Decoding to match the synthesized encoder
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            if container.allKeys.count == 1, let key = container.allKeys.first {
                self = try .init(container: container, key: key)
            } else {
                throw DecodingError.typeMismatch(
                    SettingsCommentSortType.self,
                    DecodingError.Context(
                        codingPath: container.codingPath,
                        debugDescription: "Invalid number of keys found, expected one.",
                        underlyingError: nil
                    )
                )
            }
        // Mlem 2.5 -> 2.6 upgrade
        } else if let value = try? LegacySettingsCommentSortType(from: decoder) {
            self = .init(value)
        } else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath,
                debugDescription: "SettingsCommentSortType does not match either supported schema"
            ))
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .hot:
            try container.encode([String: String](), forKey: .hot)
        case .new:
            try container.encode([String: String](), forKey: .new)
        case .old:
            try container.encode([String: String](), forKey: .old)
        case .controversial:
            try container.encode([String: String](), forKey: .controversial)
        case let .top(timeRange):
            try container.encode(timeRange, forKey: .top)
        }
    }

    private init(container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) throws {
        self = switch key {
        case .hot: .hot
        case .new: .new
        case .old: .old
        case .controversial: .controversial
        case .top:
            .top(try container.decode(SettingsSortTimeRange.self, forKey: .top))
        }
    }

    init(_ sortType: CommentSortType) {
        self = switch sortType {
        case .hot: .hot
        case .new: .new
        case .old: .old
        case .controversial: .controversial
        case let .top(timeRange): .top(.init(timeRange))
        }
    }

    private init(_ legacySortType: LegacySettingsCommentSortType) {
        let commentSortType: CommentSortType = switch legacySortType {
        case .hot: .hot
        case .new: .new
        case .old: .old
        case .controversial: .controversial
        case .top: .top(.allTime)
        }

        self.init(commentSortType)
    }
}
