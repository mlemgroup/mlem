//
//  ModlogAction.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-17.
//

import Foundation

enum ModlogAction: CaseIterable {
    case all, postRemoval, postLock, postPin, commentRemoval, communityRemoval, communityBan, instanceBan,
         moderatorAdd, communityTransfer, administratorAdd, personPurge, communityPurge, postPurge, commentPurge, communityHide
    
    var label: String {
        switch self {
        case .all:
            "All"
        case .postRemoval:
            "Removed Post"
        case .postLock:
            "Locked Post"
        case .postPin:
            "Pinned Post"
        case .commentRemoval:
            "Removed Comment"
        case .communityRemoval:
            "Removed Community"
        case .communityBan:
            "Banned from Community"
        case .instanceBan:
            "Banned from Instance"
        case .moderatorAdd:
            "Appointed Moderator"
        case .communityTransfer:
            "Transferred Community"
        case .administratorAdd:
            "Appointed Administrator"
        case .personPurge:
            "Purged Person"
        case .communityPurge:
            "Purged Community"
        case .postPurge:
            "Purged Post"
        case .commentPurge:
            "Purged Comment"
        case .communityHide:
            "Hid Community"
        }
    }
    
    static var communityActionCases: [ModlogAction] {
        [.postLock, .postPin, .moderatorAdd, .communityTransfer]
    }
    
    static var removalCases: [ModlogAction] {
        [.postRemoval, .commentRemoval, .communityRemoval]
    }
    
    static var banCases: [ModlogAction] {
        [.communityBan, .instanceBan]
    }
    
    static var instanceActionCases: [ModlogAction] {
        [.administratorAdd, .communityHide]
    }
    
    static var purgeCases: [ModlogAction] {
        [.postPurge, .commentPurge, .communityPurge, .personPurge]
    }
    
    var toApiType: APIModlogActionType? {
        switch self {
        case .all:
            nil
        case .postRemoval:
            .modRemovePost
        case .postLock:
            .modLockPost
        case .postPin:
            .modFeaturePost
        case .commentRemoval:
            .modRemoveComment
        case .communityRemoval:
            .modRemoveCommunity
        case .communityBan:
            .modBanFromCommunity
        case .instanceBan:
            .modBan
        case .moderatorAdd:
            .modAddCommunity
        case .communityTransfer:
            .modTransferCommunity
        case .administratorAdd:
            .modAdd
        case .personPurge:
            .adminPurgePerson
        case .communityPurge:
            .adminPurgeCommunity
        case .postPurge:
            .adminPurgePost
        case .commentPurge:
            .adminPurgeComment
        case .communityHide:
            .modHideCommunity
        }
    }
}
