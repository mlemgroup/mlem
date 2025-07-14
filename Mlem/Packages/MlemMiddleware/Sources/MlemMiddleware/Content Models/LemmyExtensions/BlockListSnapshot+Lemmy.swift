//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension BlockListSnapshot {
    init(from myUserInfo: LemmyMyUserInfo) {
        self.people = myUserInfo.personBlocks.reduce(into: [:]) {
            if let actorId = $1.target.apId ?? $1.target.actorId {
                $0[actorId] = $1.target.id
            }
        }
        
        self.communities = myUserInfo.communityBlocks.reduce(into: [:]) {
            if let actorId = $1.community.apId ?? $1.community.actorId {
                $0[actorId] = $1.community.id
            }
        }
        
        self.instances = myUserInfo.instanceBlocks.reduce(into: [:]) {
            let actorId: ActorIdentifier = .instance(host: $1.instance.domain)
            $0[actorId] = $1.instance.id
        }
    }
}
