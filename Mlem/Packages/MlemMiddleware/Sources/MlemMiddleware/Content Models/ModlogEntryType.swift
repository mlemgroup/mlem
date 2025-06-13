//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-13.
//

import Foundation

public enum ModlogEntryType: CaseIterable {
    case removePost
    case lockPost
    case pinPost
    case purgePost
    case removeComment
    case purgeComment
    case removeCommunity
    case purgeCommunity
    case hideCommunity
    case transferCommunityOwnership
    case updatePersonModeratorStatus
    case updatePersonAdminStatus
    case banPersonFromCommunity
    case banPersonFromInstance
    case purgePerson
    
    init?(from type: ApiModlogActionType) throws(ApiClientError) {
        let result: Self? = switch type {
        case .all: nil
        case .modRemovePost: .removePost
        case .modLockPost: .lockPost
        case .modFeaturePost: .pinPost
        case .modRemoveComment: .removeComment
        case .modRemoveCommunity: .removeCommunity
        case .modBanFromCommunity: .banPersonFromCommunity
        case .modAddCommunity: .updatePersonModeratorStatus
        case .modTransferCommunity: .transferCommunityOwnership
        case .modAdd: .updatePersonAdminStatus
        case .modBan: .banPersonFromInstance
        case .modHideCommunity: .hideCommunity
        case .adminPurgePerson: .purgePerson
        case .adminPurgeCommunity: .purgeCommunity
        case .adminPurgePost: .purgePost
        case .adminPurgeComment: .purgeComment
        case .modChangeCommunityVisibility: throw .unsupportedLemmyVersion
        case .adminBlockInstance: throw .unsupportedLemmyVersion
        case .adminAllowInstance: throw .unsupportedLemmyVersion
        }
        if let result {
            self = result
        } else {
            return nil
        }
    }
    
    var apiType: ApiModlogActionType {
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
