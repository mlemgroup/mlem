//
//  ActorIdentifiable.swift
//  Mlem
//
//  Created by Sjmarf on 15/02/2024.
//

import Foundation

/// Represents a Lemmy entity that can be represented by an ActivityPub Actor ID.
protocol ActorIdentifiable: Hashable {
    /// The URL of the entity on it's host instance. For example, "https://lemmy.ml/c/mlemapp". Useful for identifying entities across instances.
    var actorId: URL { get }
}

extension ActorIdentifiable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(actorId)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.actorId == rhs.actorId
    }
}
