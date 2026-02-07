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
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyModLockPostView) throws(ApiClientError) {
        try self.init(
            created: view.modLockPost.when_,
            moderator: view.moderator.map(Person1Snapshot.init),
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyModFeaturePostView) throws(ApiClientError) {
        try self.init(
            created: view.modFeaturePost.when_,
            moderator: view.moderator.map(Person1Snapshot.init),
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminPurgePostView) throws(ApiClientError) {
        try self.init(
            created: view.adminPurgePost.when_,
            moderator: view.admin.map(Person1Snapshot.init),
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyModRemoveCommentView) throws(ApiClientError) {
        try self.init(
            created: view.modRemoveComment.when_,
            moderator: view.moderator.map(Person1Snapshot.init),
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminPurgeCommentView) throws(ApiClientError) {
        try self.init(
            created: view.adminPurgeComment.when_,
            moderator: view.admin.map(Person1Snapshot.init),
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminRemoveCommunityView) throws(ApiClientError) {
        try self.init(
            created: view.modRemoveCommunity.when_,
            moderator: view.moderator.map(Person1Snapshot.init),
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminPurgeCommunityView) throws(ApiClientError) {
        try self.init(
            created: view.adminPurgeCommunity.when_,
            moderator: view.admin.map(Person1Snapshot.init),
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyModHideCommunityView) throws(ApiClientError) {
        try self.init(
            created: view.modHideCommunity.when_,
            moderator: view.admin.map(Person1Snapshot.init),
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyModTransferCommunityView) throws(ApiClientError) {
        try self.init(
            created: view.modTransferCommunity.when_,
            moderator: view.moderator.map(Person1Snapshot.init),
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyModAddToCommunityView) throws(ApiClientError) {
        try self.init(
            created: view.modAddCommunity.when_,
            moderator: view.moderator.map(Person1Snapshot.init),
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminAddView) throws(ApiClientError) {
        try self.init(
            created: view.modAdd.when_,
            moderator: view.moderator.map(Person1Snapshot.init),
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyModBanFromCommunityView) throws(ApiClientError) {
        try self.init(
            created: view.modBanFromCommunity.when_,
            moderator: view.moderator.map(Person1Snapshot.init),
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminBanView) throws(ApiClientError) {
        try self.init(
            created: view.modBan.when_,
            moderator: view.moderator.map(Person1Snapshot.init),
            type: .init(from: view)
        )
    }
    
    init(from view: LemmyAdminPurgePersonView) throws(ApiClientError) {
        try self.init(
            created: view.adminPurgePerson.when_,
            moderator: view.admin.map(Person1Snapshot.init),
            type: .init(from: view)
        )
    }
}
