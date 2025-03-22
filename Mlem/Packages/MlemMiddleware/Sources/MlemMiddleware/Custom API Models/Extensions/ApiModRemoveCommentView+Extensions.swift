//
//  ApiModRemoveCommentView+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-26.
//

import Foundation

extension ApiModRemoveCommentView: ModlogEntryApiBacker {
    var published: Date { modRemoveComment.published }
    var moderatorId: Int { modRemoveComment.id }
    
    @MainActor
    func type(api: ApiClient) -> ModlogEntryType {
        .removeComment(
            api.caches.comment1.getModel(api: api, from: comment),
            creator: api.caches.person1.getModel(api: api, from: otherPerson),
            post: api.caches.post1.getModel(api: api, from: post),
            community: api.caches.community1.getModel(api: api, from: community),
            removed: modRemoveComment.removed,
            reason: modRemoveComment.reason
        )
    }
}
