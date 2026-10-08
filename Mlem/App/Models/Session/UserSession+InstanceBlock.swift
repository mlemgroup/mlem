//
//  UserSession+InstanceBlock.swift
//  Mlem
//
//  Created by Sjmarf on 2026-10-04.
//

import Foundation
import MlemMiddleware

extension UserSession {
    func updateInstanceBlock(actorId: ActorIdentifier, shouldBlock: Bool, callback: ((Bool) -> Void)? = nil) {
        Task {
            guard !ongoingInstanceBlockRequests.contains(actorId) else {
                callback?(false)
                return
            }
            
            ongoingInstanceBlockRequests.insert(actorId)
            do {
                let instanceId: Int
                if let id = self.blocks?.instanceIdOfBlockedInstance(actorId: actorId) {
                    instanceId = id
                } else {
                    instanceId = try await api.getInstanceId(actorId: actorId)
                }
                try await api.blockInstance(url: actorId.url, instanceId: instanceId, block: shouldBlock)
                ongoingInstanceBlockRequests.remove(actorId)
                callback?(true)
            } catch {
                handleError(error)
                ongoingInstanceBlockRequests.remove(actorId)
                callback?(false)
            }
        }
    }
}
