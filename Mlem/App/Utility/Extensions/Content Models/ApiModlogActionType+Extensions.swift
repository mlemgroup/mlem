//
//  ApiModlogActionType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-11.
//

import Foundation
import Icons
import MlemMiddleware

extension ApiModlogActionType {
    var label: LocalizedStringResource {
        switch self {
        case .all: "All"
        case .modRemovePost: "Remove Post"
        case .modLockPost: "Lock Post"
        case .modFeaturePost: "Pin Post"
        case .modRemoveComment: "Remove Comment"
        case .modRemoveCommunity: "Remove Community"
        case .modBanFromCommunity: "Ban from Community"
        case .modAddCommunity: "Appoint Moderator"
        case .modTransferCommunity: "Transfer Community"
        case .modAdd: "Appoint Administrator"
        case .modBan: "Ban from Instance"
        case .modHideCommunity: "Hide Community"
        case .adminPurgePerson: "Purge Person"
        case .adminPurgeCommunity: "Purge Community"
        case .adminPurgePost: "Purge Post"
        case .adminPurgeComment: "Purge Comment"
        default: "Unknown"
        }
    }
    
    var contextualLabel: LocalizedStringResource {
        switch self {
        case .all: "All"
        case .modRemovePost, .modRemoveComment, .modRemoveCommunity: "Remove"
        case .modLockPost: "Lock"
        case .modFeaturePost: "Pin"
        case .modBanFromCommunity: "Ban from Community"
        case .modAddCommunity: "Appoint Moderator"
        case .modTransferCommunity: "Transfer Ownership"
        case .modAdd: "Appoint Administrator"
        case .modBan: "Ban from Instance"
        case .modHideCommunity: "Hide"
        case .adminPurgePerson, .adminPurgeCommunity, .adminPurgePost, .adminPurgeComment: "Purge"
        default: "Unknown"
        }
    }
    
    var icon: Icon {
        switch self {
        case .all: .lemmy.federatedFeed
        case .modRemovePost, .modRemoveComment, .modRemoveCommunity: .lemmy.remove
        case .modLockPost: .lemmy.addLock
        case .modFeaturePost: .lemmy.addPin
        case .modBanFromCommunity: .lemmy.banFromCommunity
        case .modAddCommunity: .lemmy.moderation
        case .modTransferCommunity: .lemmy.transferCommunity
        case .modAdd: .lemmy.administration
        case .modBan: .lemmy.banFromInstance
        case .modHideCommunity: .general.hide
        case .adminPurgePerson, .adminPurgeCommunity, .adminPurgePost, .adminPurgeComment: .lemmy.purge
        default: .general.circle
        }
    }
    
    var appliesToCommunity: Bool {
        switch self {
        case .all, .modRemovePost, .modLockPost, .modFeaturePost,
             .modRemoveComment, .modBanFromCommunity, .modAddCommunity,
             .modTransferCommunity, .modHideCommunity: true
        case .modRemoveCommunity, .modAdd, .modBan,
             .adminPurgePerson, .adminPurgeCommunity,
             .adminPurgePost, .adminPurgeComment,
             .adminAllowInstance, .adminBlockInstance: false
        }
    }
}
