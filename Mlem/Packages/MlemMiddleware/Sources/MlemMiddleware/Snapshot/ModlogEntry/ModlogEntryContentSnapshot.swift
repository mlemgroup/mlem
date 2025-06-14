//
//  ModlogEntryContentSnapshot.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-13.
//

import Foundation

public enum ModlogEntryContentSnapshot {
    case removePost(
        _ post: Post1Snapshot,
        community: Community1Snapshot,
        removed: Bool,
        reason: String?
    )
    case lockPost(
        _ post: Post1Snapshot,
        community: Community1Snapshot,
        locked: Bool
    )
    case pinPost(
        _ post: Post1Snapshot,
        community: Community1Snapshot,
        pinned: Bool,
        type: PostFeatureType
    )
    case purgePost(reason: String?)
    
    case removeComment(
        _ comment: Comment1Snapshot,
        creator: Person1Snapshot,
        post: Post1Snapshot,
        community: Community1Snapshot,
        removed: Bool,
        reason: String?
    )
    case purgeComment(reason: String?)
    
    case removeCommunity(
        _ community: Community1Snapshot,
        removed: Bool,
        reason: String?
    )
    case purgeCommunity(reason: String?)
    
    case hideCommunity(
        _ community: Community1Snapshot,
        hidden: Bool,
        reason: String?
    )
    case transferCommunityOwnership(
        person: Person1Snapshot,
        community: Community1Snapshot
    )
    
    case updatePersonModeratorStatus(
        person: Person1Snapshot,
        community: Community1Snapshot,
        appointed: Bool
    )
    case updatePersonAdminStatus(
        person: Person1Snapshot,
        appointed: Bool
    )
    case banPersonFromCommunity(
        person: Person1Snapshot,
        community: Community1Snapshot,
        banned: Bool,
        reason: String?,
        expires: Date?
    )
    case banPersonFromInstance(
        person: Person1Snapshot,
        banned: Bool,
        reason: String?,
        expires: Date?
    )
    case purgePerson(reason: String?)
    
    public init(from view: ApiModRemovePostView) throws(ApiClientError) {
        self = try .removePost(
            .init(from: view.post),
            community: .init(from: view.community),
            removed: view.modRemovePost.removed,
            reason: view.modRemovePost.reason
        )
    }
    
    public init(from view: ApiModLockPostView) throws(ApiClientError) {
        self = try .lockPost(
            .init(from: view.post),
            community: .init(from: view.community),
            locked: view.modLockPost.locked
        )
    }
    
    public init(from view: ApiModFeaturePostView) throws(ApiClientError) {
        self = try .pinPost(
            .init(from: view.post),
            community: .init(from: view.community),
            pinned: view.modFeaturePost.featured,
            type: view.modFeaturePost.isFeaturedCommunity ? .community : .instance
        )
    }
    
    public init(from view: ApiAdminPurgePostView) throws(ApiClientError) {
        self = .purgePost(reason: view.adminPurgePost.reason)
    }
    
    public init(from view: ApiModRemoveCommentView) throws(ApiClientError) {
        guard let creator = view.otherPerson ?? view.commenter else {
            throw .responseMissingRequiredData("ApiModRemoveCommentView otherPerson")
        }
        self = try .removeComment(
            .init(from: view.comment),
            creator: .init(from: creator),
            post: .init(from: view.post),
            community: .init(from: view.community),
            removed: view.modRemoveComment.removed,
            reason: view.modRemoveComment.reason
        )
    }
    
    public init(from view: ApiAdminPurgeCommentView) throws(ApiClientError) {
        self = .purgeComment(reason: view.adminPurgeComment.reason)
    }
    
    public init(from view: ApiModRemoveCommunityView) throws(ApiClientError) {
        self = try .removeCommunity(
            .init(from: view.community),
            removed: view.modRemoveCommunity.removed,
            reason: view.modRemoveCommunity.reason
        )
    }
    
    public init(from view: ApiAdminPurgeCommunityView) throws(ApiClientError) {
        self = .purgeCommunity(reason: view.adminPurgeCommunity.reason)
    }
    
    public init(from view: ApiModHideCommunityView) throws(ApiClientError) {
        self = try .hideCommunity(
            .init(from: view.community),
            hidden: view.modHideCommunity.hidden,
            reason: view.modHideCommunity.reason
        )
    }
    
    public init(from view: ApiModTransferCommunityView) throws(ApiClientError) {
        guard let moddedPerson = view.otherPerson ?? view.moddedPerson else {
            throw .responseMissingRequiredData("ApiModTransferCommunityView otherPerson")
        }
        self = try .transferCommunityOwnership(
            person: .init(from: moddedPerson),
            community: .init(from: view.community)
        )
    }
    
    public init(from view: ApiModAddCommunityView) throws(ApiClientError) {
        guard let moddedPerson = view.otherPerson ?? view.moddedPerson else {
            throw .responseMissingRequiredData("ApiModAddCommunityView otherPerson")
        }
        self = try .updatePersonModeratorStatus(
            person: .init(from: moddedPerson),
            community: .init(from: view.community),
            appointed: !view.modAddCommunity.removed
        )
    }
    
    public init(from view: ApiModAddView) throws(ApiClientError) {
        guard let moddedPerson = view.otherPerson ?? view.moddedPerson else {
            throw .responseMissingRequiredData("ApiModAddView otherPerson")
        }
        self = try .updatePersonAdminStatus(
            person: .init(from: moddedPerson),
            appointed: !view.modAdd.removed
        )
    }
    
    public init(from view: ApiModBanFromCommunityView) throws(ApiClientError) {
        guard let bannedPerson = view.otherPerson ?? view.bannedPerson else {
            throw .responseMissingRequiredData("ApiModBanFromCommunityView otherPerson")
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
            throw .responseMissingRequiredData("ApiModBanView otherPerson")
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
