//
//  ApiModlogActionType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-11.
//

import Foundation
import Icons
import MlemMiddleware

extension ModlogEntryType {
    var label: LocalizedStringResource {
        switch self {
        case .removePost: "Remove Post"
        case .lockPost: "Lock Post"
        case .pinPost: "Pin Post"
        case .removeComment: "Remove Comment"
        case .removeCommunity: "Remove Community"
        case .banPersonFromCommunity: "Ban from Community"
        case .updatePersonModeratorStatus: "Appoint Moderator"
        case .transferCommunityOwnership: "Transfer Community"
        case .updatePersonAdminStatus: "Appoint Administrator"
        case .banPersonFromInstance: "Ban from Instance"
        case .hideCommunity: "Hide Community"
        case .purgePerson: "Purge Person"
        case .purgeCommunity: "Purge Community"
        case .purgePost: "Purge Post"
        case .purgeComment: "Purge Comment"
        }
    }
    
    var contextualLabel: LocalizedStringResource {
        switch self {
        case .removePost, .removeComment, .removeCommunity: "Remove"
        case .lockPost: "Lock"
        case .pinPost: "Pin"
        case .banPersonFromCommunity: "Ban from Community"
        case .updatePersonModeratorStatus: "Appoint Moderator"
        case .transferCommunityOwnership: "Transfer Ownership"
        case .updatePersonAdminStatus: "Appoint Administrator"
        case .banPersonFromInstance: "Ban from Instance"
        case .hideCommunity: "Hide"
        case .purgePerson, .purgeCommunity, .purgePost, .purgeComment: "Purge"
        }
    }
    
    var icon: Icon {
        switch self {
        case .removePost, .removeComment, .removeCommunity: .lemmy.remove
        case .lockPost: .lemmy.addLock
        case .pinPost: .lemmy.addPin
        case .banPersonFromCommunity: .lemmy.banFromCommunity
        case .updatePersonModeratorStatus: .lemmy.moderation
        case .transferCommunityOwnership: .lemmy.transferCommunity
        case .updatePersonAdminStatus: .lemmy.administration
        case .banPersonFromInstance: .lemmy.banFromInstance
        case .hideCommunity: .general.hide
        case .purgePerson, .purgeCommunity, .purgePost, .purgeComment: .lemmy.purge
        }
    }
    
    var appliesToCommunity: Bool {
        switch self {
        case .removePost, .lockPost, .pinPost,
             .removeComment, .banPersonFromCommunity, .updatePersonModeratorStatus,
             .transferCommunityOwnership, .hideCommunity: true
        case .removeCommunity, .updatePersonAdminStatus, .banPersonFromInstance,
             .purgePerson, .purgeCommunity,
             .purgePost, .purgeComment: false
        }
    }
}
