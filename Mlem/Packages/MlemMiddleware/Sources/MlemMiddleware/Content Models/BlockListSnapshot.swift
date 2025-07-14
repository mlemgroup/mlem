//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-06.
//

import Foundation

public struct BlockListSnapshot {
    /// Mapping `actorId` to `id`.
    var people: [ActorIdentifier: Int] = .init()
    /// Mapping `actorId` to `id`.
    var communities: [ActorIdentifier: Int] = .init()
    /// Mapping `actorId` to `instanceId`.
    var instances: [ActorIdentifier: Int] = .init()
}
