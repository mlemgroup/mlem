//
//  APISiteVersionNumber.swift
//  Mlem
//
//  Created by Sjmarf on 09/09/2023.
//
import Foundation

enum SiteVersionSuffix: Equatable {
    /// The only type other than beta "-beta.x" and releaseCandidate "-rc.x" that I've seen
    /// is lemmy.blahaj.zone's "-kt.x". I'm unable to determine the meaning of this.
    case beta(Int), releaseCandidate(Int), other(String, Int? = nil)
}

extension SiteVersionSuffix: CustomStringConvertible {
    var description: String {
        switch self {
        case .beta(let int):
            return "beta.\(int)"
        case .releaseCandidate(let int):
            return "rc.\(int)"
        case .other(let string, let int):
            if let int = int {
                return "\(string).\(int)"
            }
            return string
        }
    }
}

extension SiteVersionSuffix: Comparable {
    static func < (lhs: SiteVersionSuffix, rhs: SiteVersionSuffix) -> Bool {
        switch (lhs, rhs) {
        case (.beta, .releaseCandidate):
            return true
        case (.releaseCandidate, .beta):
            return false
        case (.releaseCandidate(let iteration1), .releaseCandidate(let iteration2)):
            return iteration1 < iteration2
        case (.beta(let iteration1), .beta(let iteration2)):
            return iteration1 < iteration2
        case (.other(let string1, let iteration1), .other(let string2, let iteration2)):
            guard string1 == string2 else {
                return false
            }
            if let iteration1 = iteration1, let iteration2 = iteration2 {
                return iteration1 < iteration2
            }
            return false
        case (.beta, .other), (.releaseCandidate, .other):
            return true
        default:
            return false
        }
    }
}

enum SiteVersion: Equatable {
    
    /// Format 0.18.2
    case release(major: Int, minor: Int, patch: Int)
    /// Format 0.18.2-beta.5, 0.18.2-rc.2
    case suffixed(major: Int, minor: Int, patch: Int, suffix: SiteVersionSuffix)
    case other(String)
    case zero
    case infinity
    
    init(_ version: String) {
        
        let parts = version.split(separator: "-")
        if parts.count >= 2 {
            
            let components = parts[0].split(separator: ".").compactMap { Int($0) }
            guard components.count == 3 else {
                self = .other(version)
                return
            }
            
            var suffix: SiteVersionSuffix = .other(String(parts[1]))
            
            if parts[1].contains(".") {
                let suffixParts = parts[1].split(separator: ".")
                if suffixParts.count == 2 {
                    if let iteration = Int(suffixParts[1]) {
                        switch suffixParts[0] {
                        case "beta":
                            suffix = .beta(iteration)
                        case "rc":
                            suffix = .releaseCandidate(iteration)
                        default:
                            suffix = .other(String(suffixParts[0]), iteration)
                        }
                    }
                }
            }
            
            self = .suffixed(major: components[0], minor: components[1], patch: components[2], suffix: suffix)
                
        } else {
            let components = version.split(separator: ".").compactMap { Int($0) }
            if components.count == 3 {
                self = .release(major: components[0], minor: components[1], patch: components[2])
            } else {
                self = .other(version)
            }
        }
    }
    
    // swiftlint: disable large_tuple
    var parts: (Int, Int, Int)? {
        switch self {
        case .release(let major, let minor, let patch):
            return (major, minor, patch)
        case .suffixed(let major, let minor, let patch, _):
            return (major, minor, patch)
        default:
            return nil
        }
    }
    // swiftlint: enable large_tuple
}

extension SiteVersion: CustomStringConvertible {
    var description: String {
        switch self {
        case .zero:
            return "zero"
        case .infinity:
            return "infinity"
        case .release(let major, let minor, let patch):
            return "\(major).\(minor).\(patch)"
        case .suffixed(let major, let minor, let patch, let type):
            return "\(major).\(minor).\(patch)-\(type)"
        case .other(let string):
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

// swiftlint:disable cyclomatic_complexity
extension SiteVersion: Comparable {
    static func < (lhs: SiteVersion, rhs: SiteVersion) -> Bool {

        switch (lhs, rhs) {
            
        case (.release, .release):
            return lhs.parts! < rhs.parts!
            
        case (.zero, _), (_, .infinity):
            return true
            
        case (_, .zero), (.infinity, _):
            return false
            
        case (
            .suffixed(_, _, _, let suffix1),
            .suffixed(_, _, _, let suffix2)
        ):
            if lhs.parts! != rhs.parts! {
                return lhs.parts! < rhs.parts!
            }
            return suffix1 < suffix2
            
        case (.release, .suffixed(_, _, _, let suffix)):
            if lhs.parts! != rhs.parts! {
                return lhs.parts! < rhs.parts!
            }
            if case .other = suffix {
                return true
            } else {
                return false
            }
        case (.suffixed(_, _, _, let suffix), .release):
            if lhs.parts! != rhs.parts! {
                return lhs.parts! < rhs.parts!
            }
            if case .other = suffix {
                return false
            } else {
                return true
            }
        default:
            return false
        }
    }
}
// swiftlint:enable cyclomatic_complexity
