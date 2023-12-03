//
//  APISiteVersionNumber.swift
//  Mlem
//
//  Created by Sjmarf on 09/09/2023.
//
import Foundation

enum SiteVersion: Equatable {
    case release(major: Int, minor: Int, patch: Int)
    case other(String)
    case zero
    case infinity
    
    init(_ version: String) {
        let parts = version.split(separator: "-")
        if let firstPart = parts.first {
            let components = firstPart.split(separator: ".").compactMap { Int($0) }
            if components.count == 3 {
                self = .release(major: components[0], minor: components[1], patch: components[2])
            } else {
                self = .other(version)
            }
        } else {
            self = .other(version)
        }
    }
    
    // swiftlint: disable large_tuple
    var parts: (Int, Int, Int)? {
        switch self {
        case let .release(major, minor, patch):
            return (major, minor, patch)
        default:
            return nil
        }
    }
    // swiftlint: enable large_tuple
}

extension SiteVersion: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .release(major, minor, patch):
            hasher.combine(0)
            hasher.combine(major)
            hasher.combine(minor)
            hasher.combine(patch)
        case let .other(description):
            hasher.combine(1)
            hasher.combine(description)
        case .zero:
            hasher.combine(2)
        case .infinity:
            hasher.combine(3)
        }
    }
}

extension SiteVersion: CustomStringConvertible {
    var description: String {
        switch self {
        case .zero:
            return "zero"
        case .infinity:
            return "infinity"
        case let .release(major, minor, patch):
            return "\(major).\(minor).\(patch)"
        case let .other(string):
            return string
        }
    }
}

extension SiteVersion: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let versionString = try container.decode(String.self)
        self.init(versionString)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(String(describing: self))
    }
}

extension SiteVersion: Comparable {
    static func < (lhs: SiteVersion, rhs: SiteVersion) -> Bool {
        print(rhs, lhs)
        switch (lhs, rhs) {
        case (.release, .release):
            return lhs.parts! < rhs.parts!
            
        // TODO: don't treat other as infinity
        case (_, .other):
            print("comparing lhs to other")
            return true
        case (.other, _):
            print("comparing other to rhs")
            return false
            
        case (.zero, _), (_, .infinity):
            return true
            
        case (_, .zero), (.infinity, _):
            return false
        default:
            return false
        }
    }
}
