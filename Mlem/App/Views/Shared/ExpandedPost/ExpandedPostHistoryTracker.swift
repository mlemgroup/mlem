//
//  ExpandedPostHistoryTracker.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-22.
//

import Foundation
import MlemMiddleware

// This needs to be Observable in order for it to work in the envrionment,
// but we aren't actually using any Observable properties at present
@Observable
class ExpandedPostHistoryTracker {
    @ObservationIgnored private var postActorIds: [ActorIdentifier] = []
    @ObservationIgnored private var postToCommentMap: [ActorIdentifier: ActorIdentifier] = [:]
    
    func insert(postActorId: ActorIdentifier, commentActorId: ActorIdentifier) {
        if let index = postActorIds.firstIndex(of: postActorId) {
            postActorIds.remove(at: index)
        }
        postActorIds.append(postActorId)
        postToCommentMap[postActorId] = commentActorId
        
        if postActorIds.count > 10 {
            let removedId = postActorIds.removeFirst()
            postToCommentMap[removedId] = nil
        }
    }
    
    func retrieve(for postActorId: ActorIdentifier) -> ActorIdentifier? { postToCommentMap[postActorId] }
}
