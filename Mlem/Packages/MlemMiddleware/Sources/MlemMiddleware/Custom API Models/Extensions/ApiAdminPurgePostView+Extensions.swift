//
//  ApiAdminPurgePostView+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-26.
//

import Foundation

extension ApiAdminPurgePostView: ModlogEntryApiBacker {
    var published: Date { adminPurgePost.published }
    var moderator: ApiPerson? { admin }
    var moderatorId: Int { adminPurgePost.id }
    
    @MainActor
    func type(api: ApiClient) -> ModlogEntryType {
        .purgePost(reason: adminPurgePost.reason)
    }
}
