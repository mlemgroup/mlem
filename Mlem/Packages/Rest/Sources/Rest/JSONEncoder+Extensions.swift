//
//  File.swift
//  Rest
//
//  Created by Sjmarf on 2025-10-14.
//

import Foundation

extension JSONEncoder.DateEncodingStrategy {
    static var iso8601WithMilliseconds: Self {
        .custom { date, encoder in
            var formatter = ISO8601DateFormatter()
            // `.withFractionalSeconds` is required for the PieFed banFromCommunity request
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            var container = encoder.singleValueContainer()
            try container.encode(formatter.string(from: date))
        }
    }
}
