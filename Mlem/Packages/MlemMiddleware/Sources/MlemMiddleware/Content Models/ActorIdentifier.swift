//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-01-25.
//

import Foundation

/// An identifier for an ActivityPub entity that is unique across all federated instances. This is a wrapper of `URL`.
///
/// ## Discussion
///
/// Avoid instantiating`ActorIdentifier`directly, and instead obtain
/// instances by interacting with `ApiClient`.
///
/// Lemmy uses the following ActorIdentifier formats (this list may be incomplete, I'm not sure):
/// - `https://example.com`
/// - `https://example.com/c/name`
/// - `https://example.com/u/name`
/// - `https://example.com/post/123`
/// - `https://example.com/comment/123`
/// - `https://example.com/private_message/123`
///
/// In addition to these formats, an ActorIdentifier may use a non-Lemmy format such as:
/// - `https://fedia.io/m/fedia` (Community URL for Kbin/Mbin)
/// - `https://misskey.io/users/9h75uqwaa8` (Person URL for Misskey)
///
/// It should be noted that private messages cannot be resolved using ``ResolveObjectRequest``.
///
public struct ActorIdentifier: Hashable, Sendable {
    public let url: URL
    public let host: String
    
    /// Create an `ActorIdentifier` from a given URL.
    ///
    /// When you use this method, you *must* be sure that the provided URL is the actual ActivityPub
    /// ID for the given entity, and not just any URL pointing to it. If possible, avoid using this initialiser.
    ///
    public init?(url: URL) {
        guard let host = url.host() else { return nil }
        self.init(url: url, host: host)
    }
    
    private init(url: URL, host: String) {
        if url.pathComponents.isEmpty {
            self.url = url.appendingPathComponent("/")
        } else {
            self.url = url
        }
        self.host = host
    }
    
    public static func instance(host: String) -> Self {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        return ActorIdentifier(url: components.url!, host: host)
    }

    public var hostUrl: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        return components.url! // This will always succeed
    }
}

extension ActorIdentifier: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let url = URL(string: string) else { throw Self.DecodingError.invalidUrl }
        if let actorId = ActorIdentifier(url: url) {
            self = actorId
        } else {
            throw Self.DecodingError.invalidUrl
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(url)
    }
}

extension ActorIdentifier: CustomStringConvertible {
    public var description: String { url.description }
}

extension ActorIdentifier: CustomDebugStringConvertible {
    public var debugDescription: String { "ActorIdentifier(\(url.description))" }
}

public extension ActorIdentifier {
    enum EntityType {
        case post, comment, message, person, community, instance
    }
    
    enum DecodingError: Error {
        case invalidUrl
    }
}
