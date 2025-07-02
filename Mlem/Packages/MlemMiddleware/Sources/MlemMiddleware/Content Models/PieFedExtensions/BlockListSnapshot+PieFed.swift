//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-25.
//

import Foundation

public extension BlockListSnapshot {
    init(from myUserInfo: PieFedMyUserInfo) {
        self.people = myUserInfo.personBlocks.reduce(into: [:]) {
            $0[$1.person.actorId] = $1.target.id
        }
        
        self.communities = myUserInfo.communityBlocks.reduce(into: [:]) {
            $0[$1.community.actorId] = $1.community.id
        }
        
        self.instances = myUserInfo.instanceBlocks.reduce(into: [:]) {
            let actorId: ActorIdentifier = .instance(host: $1.instance.domain)
            $0[actorId] = $1.instance.id
        }
    }
}
