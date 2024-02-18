//
//  ListingType.swift
//  Mlem
//
//  Created by Sjmarf on 25/11/2023.
//

import Foundation

enum APIListingType: String, Codable {
    case all = "All"
    case local = "Local"
    case subscribed = "Subscribed"
    case moderatorView = "ModeratorView"
    
    // Pre 0.18.0 it appears that they used integers instead of strings here. We can remove this intialiser once we drop support for old versions. To fully support both systems, we'd also need to *encode* back into the correct integer or string format. I'd rather not go through the effort for instance versions that most people don't use any more, so I've disabled the option to edit account settings on instances running <0.18.0
    // - sjmarf

    // TODO: 0.17 deprecation remove this initialiser
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            guard let value = APIListingType(rawValue: stringValue) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Value not one of \"All\", \"Local\" or \"Subscribed\"."
                )
            }
            self = value
        } else if let intValue = try? container.decode(Int.self) {
            guard 0 ... 2 ~= intValue else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Must be an integer in range 0...2."
                )
            }
            switch intValue {
            case 0:
                self = .all
            case 1:
                self = .local
            default:
                self = .subscribed
            }
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid value"
            )
        }
    }
    
    var toFeedType: FeedType {
        switch self {
        case .all:
            return .all
        case .local:
            return .local
        case .subscribed:
            return .subscribed
        default:
            return .all
        }
    }
}
