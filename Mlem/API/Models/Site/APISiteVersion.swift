//
//  APISiteVersionNumber.swift
//  Mlem
//
//  Created by Sjmarf on 09/09/2023.
//

import Foundation

struct APISiteVersion {
    let major: Int
    let minor: Int
    let patch: Int
    
    static let infinity: APISiteVersion = .init(major: 999, minor: 0, patch: 0)
    static let zero: APISiteVersion = .init(major: 0, minor: 0, patch: 0)
}

extension APISiteVersion: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let versionString = try container.decode(String.self)
        let components = versionString.split(separator: ".").compactMap { Int($0) }

        guard components.count == 3 else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid site version number format. Must be formatted as \"x.x.x\", not \"\(versionString)\"."
            )
        }

        major = components[0]
        minor = components[1]
        patch = components[2]
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let versionString = "\(major).\(minor).\(patch)"
        try container.encode(versionString)
    }
}

extension APISiteVersion: Equatable, Comparable {
    static func < (lhs: APISiteVersion, rhs: APISiteVersion) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }
        if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        }
        return lhs.patch < rhs.patch
    }
}
