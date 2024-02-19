//
//  APIModlogActionType.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ModlogActionType.ts
enum APIModlogActionType: String, Codable {
    case all = "All"
    case modRemovePost = "ModRemovePost"
    case modLockPost = "ModLockPost"
    case modFeaturePost = "ModFeaturePost"
    case modRemoveComment = "ModRemoveComment"
    case modRemoveCommunity = "ModRemoveCommunity"
    case modBanFromCommunity = "ModBanFromCommunity"
    case modAddCommunity = "ModAddCommunity"
    case modTransferCommunity = "ModTransferCommunity"
    case modAdd = "ModAdd"
    case modBan = "ModBan"
    case modHideCommunity = "ModHideCommunity"
    case adminPurgePerson = "AdminPurgePerson"
    case adminPurgeCommunity = "AdminPurgeCommunity"
    case adminPurgePost = "AdminPurgePost"
    case adminPurgeComment = "AdminPurgeComment"
}
