//
//  ActorIdentifiable.swift
//  Mlem
//
//  Created by Sjmarf on 15/02/2024.
//

import Foundation

/// Represents a Lemmy entity that can be represented by an ``ActorIdentifier``.
public protocol ActorIdentifiable {
    // An identifier that is unique across Lemmy instances.
    var actorId: ActorIdentifier { get }
}

public extension ActorIdentifiable {
    @inlinable
    var host: String { actorId.host }
}
