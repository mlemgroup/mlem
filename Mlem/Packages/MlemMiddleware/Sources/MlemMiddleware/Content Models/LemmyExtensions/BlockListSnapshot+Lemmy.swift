//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension BlockListSnapshot {
    init(from myUserInfo: LemmyMyUserInfo) throws(ApiClientError) {
        self.people = myUserInfo.personBlocks.reduce(into: [:]) {
            if let actorId = $1.person.apId ?? $1.person.actorId {
                $0[actorId] = $1.person.id
            }
        }
        
        self.communities = myUserInfo.communityBlocks.reduce(into: [:]) {
            if let actorId = $1.community.apId ?? $1.community.actorId {
                $0[actorId] = $1.community.id
            }
        }
        
        if let instanceCommunitiesBlocks = myUserInfo.instanceCommunitiesBlocks {
            self.instances = instanceCommunitiesBlocks.reduce(into: [:]) {
                let actorId: ActorIdentifier = .instance(host: $1.domain)
                $0[actorId] = $1.id
            }
        } else if let instanceBlocks = myUserInfo.instanceBlocks {
            self.instances = instanceBlocks.reduce(into: [:]) {
                let actorId: ActorIdentifier = .instance(host: $1.instance.domain)
                $0[actorId] = $1.instance.id
            }
        } else {
            throw .responseMissingRequiredData("LemmyMyUserInfo instanceBlocks (BlockListSnapshot)")
        }
    }
}
