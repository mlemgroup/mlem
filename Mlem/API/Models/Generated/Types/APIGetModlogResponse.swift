//
//  APIGetModlogResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetModlogResponse.ts
struct APIGetModlogResponse: Codable {
    let removedPosts: [APIModRemovePostView]
    let lockedPosts: [APIModLockPostView]
    let featuredPosts: [APIModFeaturePostView]
    let removedComments: [APIModRemoveCommentView]
    let removedCommunities: [APIModRemoveCommunityView]
    let bannedFromCommunity: [APIModBanFromCommunityView]
    let banned: [APIModBanView]
    let addedToCommunity: [APIModAddCommunityView]
    let transferredToCommunity: [APIModTransferCommunityView]
    let added: [APIModAddView]
    let adminPurgedPersons: [APIAdminPurgePersonView]
    let adminPurgedCommunities: [APIAdminPurgeCommunityView]
    let adminPurgedPosts: [APIAdminPurgePostView]
    let adminPurgedComments: [APIAdminPurgeCommentView]
    let hiddenCommunities: [APIModHideCommunityView]
}
