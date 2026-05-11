//
//  ModlogEntryType+PieFed.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-12.
//

import Foundation

extension ModlogEntryType {
    var piefedApiType: PieFedModlogActionType {
        switch self {
        case .removePost: .modRemovePost
        case .lockPost: .modLockPost
        case .pinPost: .modFeaturePost
        case .purgePost: .adminPurgePost
        case .removeComment: .modRemoveComment
        case .purgeComment: .adminPurgeComment
        case .removeCommunity: .modRemoveCommunity
        case .purgeCommunity: .adminPurgeCommunity
        case .hideCommunity: .modHideCommunity
        case .transferCommunityOwnership: .modTransferCommunity
        case .updatePersonModeratorStatus: .modAddCommunity
        case .updatePersonAdminStatus: .modAdd
        case .banPersonFromCommunity: .modBanFromCommunity
        case .banPersonFromInstance: .modBan
        case .purgePerson: .adminPurgePerson
        }
    }
}
