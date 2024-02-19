//
//  APIGetModlogResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/GetModlogResponse.ts
struct APIGetModlogResponse: Codable {
    let removed_posts: [APIModRemovePostView]
    let locked_posts: [APIModLockPostView]
    let featured_posts: [APIModFeaturePostView]
    let removed_comments: [APIModRemoveCommentView]
    let removed_communities: [APIModRemoveCommunityView]
    let banned_from_community: [APIModBanFromCommunityView]
    let banned: [APIModBanView]
    let added_to_community: [APIModAddCommunityView]
    let transferred_to_community: [APIModTransferCommunityView]
    let added: [APIModAddView]
    let admin_purged_persons: [APIAdminPurgePersonView]
    let admin_purged_communities: [APIAdminPurgeCommunityView]
    let admin_purged_posts: [APIAdminPurgePostView]
    let admin_purged_comments: [APIAdminPurgeCommentView]
    let hidden_communities: [APIModHideCommunityView]
}
