//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-09-28.
//

import Foundation

extension ModlogEntryContentSnapshot {
    init(from view: LemmyModRemovePostView) throws(ApiClientError) {
        self = try .removePost(
            .init(from: view.post),
            community: .init(from: view.community),
            removed: view.modRemovePost.removed,
            reason: view.modRemovePost.reason
        )
    }
    
    init(from view: LemmyModLockPostView) throws(ApiClientError) {
        self = try .lockPost(
            .init(from: view.post),
            community: .init(from: view.community),
            locked: view.modLockPost.locked
        )
    }
    
    init(from view: LemmyModFeaturePostView) throws(ApiClientError) {
        self = try .pinPost(
            .init(from: view.post),
            community: .init(from: view.community),
            pinned: view.modFeaturePost.featured,
            type: view.modFeaturePost.isFeaturedCommunity ? .community : .instance
        )
    }
    
    init(from view: LemmyAdminPurgePostView) throws(ApiClientError) {
        self = .purgePost(reason: view.adminPurgePost.reason)
    }
    
    init(from view: LemmyModRemoveCommentView) throws(ApiClientError) {
        guard let creator = view.otherPerson ?? view.commenter else {
            throw .responseMissingRequiredData("LemmyModRemoveCommentView otherPerson")
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
    
    init(from view: LemmyAdminPurgeCommentView) throws(ApiClientError) {
        self = .purgeComment(reason: view.adminPurgeComment.reason)
    }
    
    init(from view: LemmyAdminRemoveCommunityView) throws(ApiClientError) {
        guard let inner = view.adminRemoveCommunity ?? view.modRemoveCommunity else {
            throw .responseMissingRequiredData("LemmyAdminRemoveCommunityView inner")
        }
        self = try .removeCommunity(
            .init(from: view.community),
            removed: inner.removed,
            reason: inner.reason
        )
    }
    
    init(from view: LemmyAdminPurgeCommunityView) throws(ApiClientError) {
        self = .purgeCommunity(reason: view.adminPurgeCommunity.reason)
    }
    
    init(from view: LemmyModHideCommunityView) throws(ApiClientError) {
        self = try .hideCommunity(
            .init(from: view.community),
            hidden: view.modHideCommunity.hidden,
            reason: view.modHideCommunity.reason
        )
    }
    
    init(from view: LemmyModTransferCommunityView) throws(ApiClientError) {
        guard let moddedPerson = view.otherPerson ?? view.moddedPerson else {
            throw .responseMissingRequiredData("LemmyModTransferCommunityView otherPerson")
        }
        self = try .transferCommunityOwnership(
            person: .init(from: moddedPerson),
            community: .init(from: view.community)
        )
    }
    
    init(from view: LemmyModAddToCommunityView) throws(ApiClientError) {
        guard let moddedPerson = view.otherPerson ?? view.moddedPerson else {
            throw .responseMissingRequiredData("LemmyModAddCommunityView otherPerson")
        }
        guard let inner = view.modAddToCommunity ?? view.modAddCommunity else {
            throw .responseMissingRequiredData("LemmyModAddToCommunityView inner")
        }
        self = try .updatePersonModeratorStatus(
            person: .init(from: moddedPerson),
            community: .init(from: view.community),
            appointed: !inner.removed
        )
    }
    
    init(from view: LemmyAdminAddView) throws(ApiClientError) {
        guard let moddedPerson = view.otherPerson ?? view.moddedPerson else {
            throw .responseMissingRequiredData("LemmyModAddView otherPerson")
        }
        guard let inner = view.adminAdd ?? view.modAdd else {
            throw .responseMissingRequiredData("LemmyAdminAddView inner")
        }
        self = try .updatePersonAdminStatus(
            person: .init(from: moddedPerson),
            appointed: !inner.removed
        )
    }
    
    init(from view: LemmyModBanFromCommunityView) throws(ApiClientError) {
        guard let bannedPerson = view.otherPerson ?? view.bannedPerson else {
            throw .responseMissingRequiredData("LemmyModBanFromCommunityView otherPerson")
        }
        self = try .banPersonFromCommunity(
            person: .init(from: bannedPerson),
            community: .init(from: view.community),
            banned: view.modBanFromCommunity.banned,
            reason: view.modBanFromCommunity.reason,
            expires: view.modBanFromCommunity.expires
        )
    }
    
    init(from view: LemmyAdminBanView) throws(ApiClientError) {
        guard let bannedPerson = view.otherPerson ?? view.bannedPerson else {
            throw .responseMissingRequiredData("LemmyModBanView otherPerson")
        }
        guard let inner = view.adminBan ?? view.modBan else {
            throw .responseMissingRequiredData("LemmyAdminBanView inner")
        }
        self = try .banPersonFromInstance(
            person: .init(from: bannedPerson),
            banned: inner.banned,
            reason: inner.reason,
            expires: inner.expires
        )
    }
    
    init(from view: LemmyAdminPurgePersonView) throws(ApiClientError) {
        self = .purgePerson(reason: view.adminPurgePerson.reason)
    }
}
