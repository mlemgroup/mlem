//
//  ApiModlogActionType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-11.
//

import Foundation
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
        }
    }
    
    var systemImage: String {
        switch self {
        case .all: Icons.federatedFeed
        case .modRemovePost, .modRemoveComment, .modRemoveCommunity: Icons.remove
        case .modLockPost: Icons.lock
        case .modFeaturePost: Icons.pin
        case .modBanFromCommunity: Icons.banFromCommunity
        case .modAddCommunity: Icons.moderation
        case .modTransferCommunity: Icons.transferCommunity
        case .modAdd: Icons.administration
        case .modBan: Icons.banFromInstance
        case .modHideCommunity: Icons.hide
        case .adminPurgePerson, .adminPurgeCommunity, .adminPurgePost, .adminPurgeComment: Icons.purge
        }
    }
    
    var appliesToCommunity: Bool {
        switch self {
        case .all, .modRemovePost, .modLockPost, .modFeaturePost,
             .modRemoveComment, .modBanFromCommunity, .modAddCommunity,
             .modTransferCommunity, .modHideCommunity: true
        case .modRemoveCommunity, .modAdd, .modBan,
             .adminPurgePerson, .adminPurgeCommunity,
             .adminPurgePost, .adminPurgeComment: false
        }
    }
}
