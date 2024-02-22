//
//  ApiGetModlogResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetModlogResponse.ts
struct ApiGetModlogResponse: Codable {
    let removedPosts: [ApiModRemovePostView]
    let lockedPosts: [ApiModLockPostView]
    let featuredPosts: [ApiModFeaturePostView]
    let removedComments: [ApiModRemoveCommentView]
    let removedCommunities: [ApiModRemoveCommunityView]
    let bannedFromCommunity: [ApiModBanFromCommunityView]
    let banned: [ApiModBanView]
    let addedToCommunity: [ApiModAddCommunityView]
    let transferredToCommunity: [ApiModTransferCommunityView]
    let added: [ApiModAddView]
    let adminPurgedPersons: [ApiAdminPurgePersonView]
    let adminPurgedCommunities: [ApiAdminPurgeCommunityView]
    let adminPurgedPosts: [ApiAdminPurgePostView]
    let adminPurgedComments: [ApiAdminPurgeCommentView]
    let hiddenCommunities: [ApiModHideCommunityView]
}
