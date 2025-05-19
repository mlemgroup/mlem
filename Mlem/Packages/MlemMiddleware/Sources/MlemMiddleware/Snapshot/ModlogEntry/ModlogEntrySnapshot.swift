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
    public let type: ModlogEntryTypeSnapshot
    
    public init(from view: ApiModRemovePostView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modRemovePost.modPersonId
        if let created = view.modRemovePost.when_ ?? view.modRemovePost.published {
            self.created = created
        } else {
            throw .responseMissingRequiredData("ApiModRemovePostView created")
        }
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiModLockPostView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modLockPost.modPersonId
        if let created = view.modLockPost.when_ ?? view.modLockPost.published {
            self.created = created
        } else {
            throw .responseMissingRequiredData("ApiModLockPostView created")
        }
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiModFeaturePostView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modFeaturePost.modPersonId
        if let created = view.modFeaturePost.when_ ?? view.modFeaturePost.published {
            self.created = created
        } else {
            throw .responseMissingRequiredData("ApiModFeaturePostView created")
        }
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiAdminPurgePostView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.adminPurgePost.adminPersonId
        if let created = view.adminPurgePost.when_ ?? view.adminPurgePost.published {
            self.created = created
        } else {
            throw .responseMissingRequiredData("ApiAdminPurgePostView created")
        }
        self.moderator = try view.admin.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiModRemoveCommentView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modRemoveComment.modPersonId
        if let created = view.modRemoveComment.when_ ?? view.modRemoveComment.published {
            self.created = created
        } else {
            throw .responseMissingRequiredData("ApiModRemoveCommentView created")
        }
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiAdminPurgeCommentView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.adminPurgeComment.adminPersonId
        if let created = view.adminPurgeComment.when_ ?? view.adminPurgeComment.published {
            self.created = created
        } else {
            throw .responseMissingRequiredData("ApiAdminPurgeCommentView created")
        }
        self.moderator = try view.admin.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiModRemoveCommunityView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modRemoveCommunity.modPersonId
        if let created = view.modRemoveCommunity.when_ ?? view.modRemoveCommunity.published {
            self.created = created
        } else {
            throw .responseMissingRequiredData("ApiModRemoveCommunityView created")
        }
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiAdminPurgeCommunityView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.adminPurgeCommunity.adminPersonId
        if let created = view.adminPurgeCommunity.when_ ?? view.adminPurgeCommunity.published {
            self.created = created
        } else {
            throw .responseMissingRequiredData("ApiAdminPurgeCommunityView created")
        }
        self.moderator = try view.admin.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiModHideCommunityView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modHideCommunity.modPersonId
        self.created = view.modHideCommunity.when_
        self.moderator = try view.admin.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiModTransferCommunityView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modTransferCommunity.modPersonId
        if let created = view.modTransferCommunity.when_ ?? view.modTransferCommunity.published {
            self.created = created
        } else {
            throw .responseMissingRequiredData("ApiModTransferCommunityView created")
        }
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiModAddCommunityView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modAddCommunity.modPersonId
        if let created = view.modAddCommunity.when_ ?? view.modAddCommunity.published {
            self.created = created
        } else {
            throw .responseMissingRequiredData("ApiModAddCommunityView created")
        }
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiModAddView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modAdd.modPersonId
        if let created = view.modAdd.when_ ?? view.modAdd.published {
            self.created = created
        } else {
            throw .responseMissingRequiredData("ApiModAddView created")
        }
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiModBanFromCommunityView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modBanFromCommunity.modPersonId
        if let created = view.modBanFromCommunity.when_ ?? view.modBanFromCommunity.published {
            self.created = created
        } else {
            throw .responseMissingRequiredData("ApiModBanFromCommunityView created")
        }
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiModBanView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modBan.modPersonId
        if let created = view.modBan.when_ ?? view.modBan.published {
            self.created = created
        } else {
            throw .responseMissingRequiredData("ApiModBanView created")
        }
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiAdminPurgePersonView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.adminPurgePerson.adminPersonId
        if let created = view.adminPurgePerson.when_ ?? view.adminPurgePerson.published {
            self.created = created
        } else {
            throw .responseMissingRequiredData("ApiAdminPurgePersonView created")
        }
        self.moderator = try view.admin.map(Person1Snapshot.init)
    }
}
