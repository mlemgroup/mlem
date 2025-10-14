//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-09-28.
//

import Foundation

extension ModlogEntrySnapshot {
    init(from view: LemmyModRemovePostView) throws(ApiClientError) {
        guard let created = view.modRemovePost.when_ ?? view.modRemovePost.publishedAt else {
            throw .responseMissingRequiredData("LemmyModRemovePostView created")
        }
        try self.init(
            created: created,
            moderator: view.moderator.map(Person1Snapshot.init),
            moderatorId: view.modRemovePost.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyModLockPostView) throws(ApiClientError) {
        guard let created = view.modLockPost.when_ ?? view.modLockPost.publishedAt else {
            throw .responseMissingRequiredData("LemmyModLockPostView created")
        }
        try self.init(
            created: created,
            moderator: view.moderator.map(Person1Snapshot.init),
            moderatorId: view.modLockPost.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyModFeaturePostView) throws(ApiClientError) {
        guard let created = view.modFeaturePost.when_ ?? view.modFeaturePost.publishedAt else {
            throw .responseMissingRequiredData("LemmyModFeaturePostView created")
        }
        try self.init(
            created: created,
            moderator: view.moderator.map(Person1Snapshot.init),
            moderatorId: view.modFeaturePost.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminPurgePostView) throws(ApiClientError) {
        guard let created = view.adminPurgePost.when_ ?? view.adminPurgePost.publishedAt else {
            throw .responseMissingRequiredData("LemmyAdminPurgePostView created")
        }
        try self.init(
            created: created,
            moderator: view.admin.map(Person1Snapshot.init),
            moderatorId: view.adminPurgePost.adminPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyModRemoveCommentView) throws(ApiClientError) {
        guard let created = view.modRemoveComment.when_ ?? view.modRemoveComment.publishedAt else {
            throw .responseMissingRequiredData("LemmyModRemoveCommentView created")
        }
        try self.init(
            created: created,
            moderator: view.moderator.map(Person1Snapshot.init),
            moderatorId: view.modRemoveComment.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminPurgeCommentView) throws(ApiClientError) {
        guard let created = view.adminPurgeComment.when_ ?? view.adminPurgeComment.publishedAt else {
            throw .responseMissingRequiredData("LemmyAdminPurgeCommentView created")
        }
        try self.init(
            created: created,
            moderator: view.admin.map(Person1Snapshot.init),
            moderatorId: view.adminPurgeComment.adminPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminRemoveCommunityView) throws(ApiClientError) {
        guard let inner = view.adminRemoveCommunity ?? view.modRemoveCommunity else {
            throw .responseMissingRequiredData("LemmyAdminRemoveCommunityView inner")
        }
        guard let created = inner.when_ ?? inner.publishedAt else {
            throw .responseMissingRequiredData("LemmyModRemoveCommunityView created")
        }
        try self.init(
            created: created,
            moderator: view.moderator.map(Person1Snapshot.init),
            moderatorId: inner.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminPurgeCommunityView) throws(ApiClientError) {
        guard let created = view.adminPurgeCommunity.when_ ?? view.adminPurgeCommunity.publishedAt else {
            throw .responseMissingRequiredData("LemmyAdminPurgeCommunityView created")
        }
        try self.init(
            created: created,
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
        guard let created = view.modTransferCommunity.when_ ?? view.modTransferCommunity.publishedAt else {
            throw .responseMissingRequiredData("LemmyModTransferCommunityView created")
        }
        try self.init(
            created: created,
            moderator: view.moderator.map(Person1Snapshot.init),
            moderatorId: view.modTransferCommunity.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyModAddToCommunityView) throws(ApiClientError) {
        guard let inner = view.modAddToCommunity ?? view.modAddCommunity else {
            throw .responseMissingRequiredData("LemmyModAddToCommunityView inner")
        }
        guard let created = inner.when_ ?? inner.publishedAt else {
            throw .responseMissingRequiredData("LemmyModAddCommunityView created")
        }
        try self.init(
            created: created,
            moderator: view.moderator.map(Person1Snapshot.init),
            moderatorId: inner.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminAddView) throws(ApiClientError) {
        guard let inner = view.adminAdd ?? view.modAdd else {
            throw .responseMissingRequiredData("LemmyAdminAddView inner")
        }
        guard let created = inner.when_ ?? inner.publishedAt else {
            throw .responseMissingRequiredData("LemmyModAddView created")
        }
        try self.init(
            created: created,
            moderator: view.moderator.map(Person1Snapshot.init),
            moderatorId: inner.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyModBanFromCommunityView) throws(ApiClientError) {
        guard let created = view.modBanFromCommunity.when_ ?? view.modBanFromCommunity.publishedAt else {
            throw .responseMissingRequiredData("LemmyModBanFromCommunityView created")
        }
        try self.init(
            created: created,
            moderator: view.moderator.map(Person1Snapshot.init),
            moderatorId: view.modBanFromCommunity.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminBanView) throws(ApiClientError) {
        guard let inner = view.adminBan ?? view.modBan else {
            throw .responseMissingRequiredData("LemmyAdminBanView inner")
        }
        guard let created = inner.when_ ?? inner.publishedAt else {
            throw .responseMissingRequiredData("LemmyModBanView created")
        }
        try self.init(
            created: created,
            moderator: view.moderator.map(Person1Snapshot.init),
            moderatorId: inner.modPersonId,
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminPurgePersonView) throws(ApiClientError) {
        guard let created = view.adminPurgePerson.when_ ?? view.adminPurgePerson.publishedAt else {
            throw .responseMissingRequiredData("LemmyAdminPurgePersonView created")
        }
        try self.init(
            created: created,
            moderator: view.admin.map(Person1Snapshot.init),
            moderatorId: view.adminPurgePerson.adminPersonId,
            type: .init(from: view)
        )
    }
}
