//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-13.
//

import Foundation

public struct ModlogEntrySnapshot {
    public let created: Date
    public let moderator: Person1Snapshot?
    public let moderatorId: Int
    public let type: ModlogEntryContentSnapshot
    
    public init(from view: LemmyModRemovePostView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modRemovePost.modPersonId
        if let created = view.modRemovePost.when_ ?? view.modRemovePost.publishedAt {
            self.created = created
        } else {
            throw .responseMissingRequiredData("LemmyModRemovePostView created")
        }
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: LemmyModLockPostView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modLockPost.modPersonId
        if let created = view.modLockPost.when_ ?? view.modLockPost.publishedAt {
            self.created = created
        } else {
            throw .responseMissingRequiredData("LemmyModLockPostView created")
        }
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: LemmyModFeaturePostView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modFeaturePost.modPersonId
        if let created = view.modFeaturePost.when_ ?? view.modFeaturePost.publishedAt {
            self.created = created
        } else {
            throw .responseMissingRequiredData("LemmyModFeaturePostView created")
        }
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: LemmyAdminPurgePostView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.adminPurgePost.adminPersonId
        if let created = view.adminPurgePost.when_ ?? view.adminPurgePost.publishedAt {
            self.created = created
        } else {
            throw .responseMissingRequiredData("LemmyAdminPurgePostView created")
        }
        self.moderator = try view.admin.map(Person1Snapshot.init)
    }
    
    public init(from view: LemmyModRemoveCommentView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modRemoveComment.modPersonId
        if let created = view.modRemoveComment.when_ ?? view.modRemoveComment.publishedAt {
            self.created = created
        } else {
            throw .responseMissingRequiredData("LemmyModRemoveCommentView created")
        }
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: LemmyAdminPurgeCommentView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.adminPurgeComment.adminPersonId
        if let created = view.adminPurgeComment.when_ ?? view.adminPurgeComment.publishedAt {
            self.created = created
        } else {
            throw .responseMissingRequiredData("LemmyAdminPurgeCommentView created")
        }
        self.moderator = try view.admin.map(Person1Snapshot.init)
    }
    
    public init(from view: LemmyModRemoveCommunityView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modRemoveCommunity.modPersonId
        if let created = view.modRemoveCommunity.when_ ?? view.modRemoveCommunity.publishedAt {
            self.created = created
        } else {
            throw .responseMissingRequiredData("LemmyModRemoveCommunityView created")
        }
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: LemmyAdminPurgeCommunityView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.adminPurgeCommunity.adminPersonId
        if let created = view.adminPurgeCommunity.when_ ?? view.adminPurgeCommunity.publishedAt {
            self.created = created
        } else {
            throw .responseMissingRequiredData("LemmyAdminPurgeCommunityView created")
        }
        self.moderator = try view.admin.map(Person1Snapshot.init)
    }
    
    public init(from view: LemmyModHideCommunityView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modHideCommunity.modPersonId
        self.created = view.modHideCommunity.when_
        self.moderator = try view.admin.map(Person1Snapshot.init)
    }
    
    public init(from view: LemmyModTransferCommunityView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modTransferCommunity.modPersonId
        if let created = view.modTransferCommunity.when_ ?? view.modTransferCommunity.publishedAt {
            self.created = created
        } else {
            throw .responseMissingRequiredData("LemmyModTransferCommunityView created")
        }
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: LemmyModAddCommunityView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modAddCommunity.modPersonId
        if let created = view.modAddCommunity.when_ ?? view.modAddCommunity.publishedAt {
            self.created = created
        } else {
            throw .responseMissingRequiredData("LemmyModAddCommunityView created")
        }
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: LemmyModAddView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modAdd.modPersonId
        if let created = view.modAdd.when_ ?? view.modAdd.publishedAt {
            self.created = created
        } else {
            throw .responseMissingRequiredData("LemmyModAddView created")
        }
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: LemmyModBanFromCommunityView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modBanFromCommunity.modPersonId
        if let created = view.modBanFromCommunity.when_ ?? view.modBanFromCommunity.publishedAt {
            self.created = created
        } else {
            throw .responseMissingRequiredData("LemmyModBanFromCommunityView created")
        }
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: LemmyModBanView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modBan.modPersonId
        if let created = view.modBan.when_ ?? view.modBan.publishedAt {
            self.created = created
        } else {
            throw .responseMissingRequiredData("LemmyModBanView created")
        }
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: LemmyAdminPurgePersonView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.adminPurgePerson.adminPersonId
        if let created = view.adminPurgePerson.when_ ?? view.adminPurgePerson.publishedAt {
            self.created = created
        } else {
            throw .responseMissingRequiredData("LemmyAdminPurgePersonView created")
        }
        self.moderator = try view.admin.map(Person1Snapshot.init)
    }
}
