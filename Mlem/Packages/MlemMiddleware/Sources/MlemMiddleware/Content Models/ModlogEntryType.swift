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
    
    init?(from type: LemmyModlogKind) throws(ApiClientError) {
        let result: Self? = switch type {
        case .all: nil
        case .modRemovePost: .removePost
        case .modLockPost: .lockPost
        case .modFeaturePost: .pinPost
        case .modRemoveComment: .removeComment
        case .modBanFromCommunity: .banPersonFromCommunity
        case .modAddToCommunity, .modAddCommunity: .updatePersonModeratorStatus
        case .modTransferCommunity: .transferCommunityOwnership
        case .modHideCommunity: .hideCommunity
        case .adminAdd, .modAdd: .updatePersonAdminStatus
        case .adminBan, .modBan: .banPersonFromInstance
        case .adminRemoveCommunity, .modRemoveCommunity: .removeCommunity
        case .adminPurgePerson: .purgePerson
        case .adminPurgeCommunity: .purgeCommunity
        case .adminPurgePost: .purgePost
        case .adminPurgeComment: .purgeComment
        case .modChangeCommunityVisibility: throw .featureUnsupported
        case .adminBlockInstance: throw .featureUnsupported
        case .adminAllowInstance: throw .featureUnsupported
        case .modLockComment: throw .featureUnsupported
        case .adminFeaturePostSite: throw .featureUnsupported
        case .modFeaturePostCommunity: throw .featureUnsupported
        case .modWarnPost: throw .featureUnsupported
        case .modWarnComment: throw .featureUnsupported
        }
        if let result {
            self = result
        } else {
            return nil
        }
    }
    
    var apiType: LemmyModlogKind {
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
