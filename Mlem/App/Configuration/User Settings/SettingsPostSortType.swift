//
//  SettingsPostSortType.swift
//  Mlem
//
//  Created by Sjmarf on 2026-09-10.
//

import Foundation
import MlemMiddleware

enum SettingsPostSortType: Codable {
    case active
    case hot
    case new
    case old
    case mostComments
    case newComments
    case controversial
    case scaled

    case top(SettingsSortTimeRange)

    enum CodingKeys: CodingKey {
        case active, hot, new, old, mostComments, newComments, controversial, scaled, top
    }

    init(from decoder: any Decoder) throws {
        // Decoding to match the synthesized encoder
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            if container.allKeys.count == 1, let key = container.allKeys.first {
                self = try .init(container: container, key: key)
            } else {
                throw DecodingError.typeMismatch(
                    SettingsPostSortType.self,
                    DecodingError.Context(
                        codingPath: container.codingPath,
                        debugDescription: "Invalid number of keys found, expected one.",
                        underlyingError: nil
                    )
                )
            }
        // Mlem 2.5 -> 2.6 upgrade
        } else if let value = try? LegacySettingsPostSortType(from: decoder) {
            self = .init(value)
        } else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath,
                debugDescription: "SettingsPostSortType does not match either supported schema"
            ))
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .active:
            try container.encode([String: String](), forKey: .active)
        case .hot:
            try container.encode([String: String](), forKey: .hot)
        case .new:
            try container.encode([String: String](), forKey: .new)
        case .old:
            try container.encode([String: String](), forKey: .old)
        case .mostComments:
            try container.encode([String: String](), forKey: .mostComments)
        case .newComments:
            try container.encode([String: String](), forKey: .newComments)
        case .controversial:
            try container.encode([String: String](), forKey: .controversial)
        case .scaled:
            try container.encode([String: String](), forKey: .scaled)
        case let .top(timeRange):
            try container.encode(timeRange, forKey: .top)
        }
    }

    private init(container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) throws {
        self = switch key {
        case .active: .active
        case .hot: .hot
        case .new: .new
        case .old: .old
        case .mostComments: .mostComments
        case .newComments: .newComments
        case .controversial: .controversial
        case .scaled: .scaled
        case .top:
            .top(try container.decode(SettingsSortTimeRange.self, forKey: .top))
        }
    }

    init(_ sortType: PostSortType) {
        self = switch sortType {
        case .active: .active
        case .hot: .hot
        case .new: .new
        case .old: .old
        case .mostComments: .mostComments
        case .newComments: .newComments
        case .controversial: .controversial
        case .scaled: .scaled
        case let .top(timeRange): .top(.init(timeRange))
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private init(_ legacySortType: LegacySettingsPostSortType) {
        let postSortType: PostSortType = switch legacySortType {
        case .active: .active
        case .hot: .hot
        case .new: .new
        case .old: .old
        case .mostComments: .mostComments
        case .newComments: .newComments
        case .controversial: .controversial
        case .scaled: .scaled
        case .topAll: .top(.allTime)
        case .topDay: .top(.limited(.day))
        case .topWeek: .top(.limited(.week))
        case .topMonth: .top(.limited(.month))
        case .topYear: .top(.limited(.year))
        case .topHour: .top(.limited(.hour))
        case .topSixHour: .top(.limited(.sixHour))
        case .topTwelveHour: .top(.limited(.twelveHour))
        case .topThreeMonths: .top(.limited(.threeMonth))
        case .topSixMonths: .top(.limited(.sixMonth))
        case .topNineMonths: .top(.limited(.nineMonth))
        } 

        self.init(postSortType)
    }
}

enum SettingsSortTimeRange: Codable {
    case allTime
    case limited(TimeInterval)

    init(_ timeRange: SortTimeRange) {
        self = switch timeRange {
        case .allTime: .allTime
        case let .limited(duration): .limited(duration)
        }
    }
}
