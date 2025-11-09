//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-09-28.
//

import Foundation

extension ModlogEntrySnapshot {
    init(from view: LemmyModRemovePostView) throws(ApiClientError) {
        try self.init(
            created: view.modRemovePost.when_,
            moderator: view.moderator.map(Person1Snapshot.init),
            moderatorId: view.modRemovePost.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyModLockPostView) throws(ApiClientError) {
        try self.init(
            created: view.modLockPost.when_,
            moderator: view.moderator.map(Person1Snapshot.init),
            moderatorId: view.modLockPost.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyModFeaturePostView) throws(ApiClientError) {
        try self.init(
            created: view.modFeaturePost.when_,
            moderator: view.moderator.map(Person1Snapshot.init),
            moderatorId: view.modFeaturePost.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminPurgePostView) throws(ApiClientError) {
        try self.init(
            created: view.adminPurgePost.when_,
            moderator: view.admin.map(Person1Snapshot.init),
            moderatorId: view.adminPurgePost.adminPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyModRemoveCommentView) throws(ApiClientError) {
        try self.init(
            created: view.modRemoveComment.when_,
            moderator: view.moderator.map(Person1Snapshot.init),
            moderatorId: view.modRemoveComment.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminPurgeCommentView) throws(ApiClientError) {
        try self.init(
            created: view.adminPurgeComment.when_,
            moderator: view.admin.map(Person1Snapshot.init),
            moderatorId: view.adminPurgeComment.adminPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminRemoveCommunityView) throws(ApiClientError) {
        try self.init(
            created: view.modRemoveCommunity.when_,
            moderator: view.moderator.map(Person1Snapshot.init),
            moderatorId: view.modRemoveCommunity.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminPurgeCommunityView) throws(ApiClientError) {
        try self.init(
            created: view.adminPurgeCommunity.when_,
            moderator: view.admin.map(Person1Snapshot.init),
            moderatorId: view.adminPurgeCommunity.adminPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyModHideCommunityView) throws(ApiClientError) {
        try self.init(
            created: view.modHideCommunity.when_,
            moderator: view.admin.map(Person1Snapshot.init),
            moderatorId: view.modHideCommunity.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyModTransferCommunityView) throws(ApiClientError) {
        try self.init(
            created: view.modTransferCommunity.when_,
            moderator: view.moderator.map(Person1Snapshot.init),
            moderatorId: view.modTransferCommunity.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyModAddToCommunityView) throws(ApiClientError) {
        try self.init(
            created: view.modAddCommunity.when_,
            moderator: view.moderator.map(Person1Snapshot.init),
            moderatorId: view.modAddCommunity.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminAddView) throws(ApiClientError) {
        try self.init(
            created: view.modAdd.when_,
            moderator: view.moderator.map(Person1Snapshot.init),
            moderatorId: view.modAdd.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyModBanFromCommunityView) throws(ApiClientError) {
        try self.init(
            created: view.modBanFromCommunity.when_,
            moderator: view.moderator.map(Person1Snapshot.init),
            moderatorId: view.modBanFromCommunity.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminBanView) throws(ApiClientError) {
        try self.init(
            created: view.modBan.when_,
            moderator: view.moderator.map(Person1Snapshot.init),
            moderatorId: view.modBan.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminPurgePersonView) throws(ApiClientError) {
        try self.init(
            created: view.adminPurgePerson.when_,
            moderator: view.admin.map(Person1Snapshot.init),
            moderatorId: view.adminPurgePerson.adminPersonId,
            type: .init(from: view)
        )
    }
}
