//
//  ModlogEntryType+Lemmy.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-12.
//

import Foundation

extension ModlogEntryType {
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

    func lemmyApiType(endpoint: LemmyEndpointVersion) -> LemmyModlogKind {
        switch (self, endpoint) {
        case (.removePost, _): .modRemovePost
        case (.lockPost, _): .modLockPost
        case (.pinPost, _): .modFeaturePost
        case (.purgePost, _): .adminPurgePost
        case (.removeComment, _): .modRemoveComment
        case (.purgeComment, _): .adminPurgeComment
        case (.removeCommunity, _): .modRemoveCommunity
        case (.purgeCommunity, _): .adminPurgeCommunity
        case (.hideCommunity, _): .modHideCommunity
        case (.transferCommunityOwnership, _): .modTransferCommunity
        case (.updatePersonModeratorStatus, _): .modAddCommunity
        case (.updatePersonAdminStatus, _): .modAdd
        case (.banPersonFromCommunity, _): .modBanFromCommunity
        case (.banPersonFromInstance, _): .modBan
        case (.purgePerson, _): .adminPurgePerson
        }
    }
}
