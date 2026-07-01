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
        case (.pinPost, .v3): .modFeaturePost
        case (.pinPost, .v4): .modFeaturePostCommunity // TODO support site
        case (.purgePost, _): .adminPurgePost
        case (.removeComment, _): .modRemoveComment
        case (.purgeComment, _): .adminPurgeComment
        case (.removeCommunity, .v3): .modRemoveCommunity
        case (.removeCommunity, .v4): .adminRemoveCommunity
        case (.purgeCommunity, _): .adminPurgeCommunity
        case (.hideCommunity, .v3): .modHideCommunity
        case (.hideCommunity, .v4): .modChangeCommunityVisibility // TODO
        case (.transferCommunityOwnership, _): .modTransferCommunity
        case (.updatePersonModeratorStatus, .v3): .modAddCommunity
        case (.updatePersonModeratorStatus, .v4): .modAddToCommunity
        case (.updatePersonAdminStatus, .v3): .modAdd
        case (.updatePersonAdminStatus, .v4): .adminAdd
        case (.banPersonFromCommunity, _): .modBanFromCommunity
        case (.banPersonFromInstance, .v3): .modBan
        case (.banPersonFromInstance, .v4): .adminBan
        case (.purgePerson, _): .adminPurgePerson
        }
    }
}
