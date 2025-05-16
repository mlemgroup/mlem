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
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiModLockPostView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modLockPost.modPersonId
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiModFeaturePostView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modFeaturePost.modPersonId
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiAdminPurgePostView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.adminPurgePost.adminPersonId
        self.moderator = try view.admin.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiModRemoveCommentView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modRemoveComment.modPersonId
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiAdminPurgeCommentView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.adminPurgeComment.adminPersonId
        self.moderator = try view.admin.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiModRemoveCommunityView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modRemoveCommunity.modPersonId
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiAdminPurgeCommunityView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.adminPurgeCommunity.adminPersonId
        self.moderator = try view.admin.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiModHideCommunityView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modHideCommunity.modPersonId
        self.moderator = try view.admin.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiModTransferCommunityView) throws(ApiClientError) {
        self.type = try .init(from: view)
        self.moderatorId = view.modTransferCommunity.modPersonId
        self.moderator = try view.moderator.map(Person1Snapshot.init)
    }
    
    public init(from view: ApiModAddCommunityView) throws(ApiClientError) {
        guard let moddedPerson = view.otherPerson ?? view.moddedPerson else {
            throw .responseMissingRequiredData
        }
        self = try .updatePersonModeratorStatus(
            person: .init(from: moddedPerson),
            community: .init(from: view.community),
            appointed: !view.modAddCommunity.removed
        )
    }
    
    public init(from view: ApiModAddView) throws(ApiClientError) {
        guard let moddedPerson = view.otherPerson ?? view.moddedPerson else {
            throw .responseMissingRequiredData
        }
        self = try .updatePersonAdminStatus(
            person: .init(from: moddedPerson),
            appointed: !view.modAdd.removed
        )
    }
    
    public init(from view: ApiModBanFromCommunityView) throws(ApiClientError) {
        guard let bannedPerson = view.otherPerson ?? view.bannedPerson else {
            throw .responseMissingRequiredData
        }
        self = try .banPersonFromCommunity(
            person: .init(from: bannedPerson),
            community: .init(from: view.community),
            banned: view.modBanFromCommunity.banned,
            reason: view.modBanFromCommunity.reason,
            expires: view.modBanFromCommunity.expires
        )
    }
    
    public init(from view: ApiModBanView) throws(ApiClientError) {
        guard let bannedPerson = view.otherPerson ?? view.bannedPerson else {
            throw .responseMissingRequiredData
        }
        self = try .banPersonFromInstance(
            person: .init(from: bannedPerson),
            banned: view.modBan.banned,
            reason: view.modBan.reason,
            expires: view.modBan.expires
        )
    }
    
    public init(from view: ApiAdminPurgePersonView) throws(ApiClientError) {
        self = .purgePerson(reason: view.adminPurgePerson.reason)
    }
}
