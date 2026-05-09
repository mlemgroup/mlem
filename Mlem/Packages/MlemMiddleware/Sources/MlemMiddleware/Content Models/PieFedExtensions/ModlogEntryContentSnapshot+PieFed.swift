//
//  ModlogEntryContentSnapshot+PieFed.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-12.
//

import Foundation

extension ModlogEntryContentSnapshot {
    init(from view: PieFedModRemovePostView) throws(ApiClientError) {
        guard let community = view.community else {
            throw ApiClientError.responseMissingRequiredData("PieFedModRemovePostView community")
        }
        self = try .removePost(
            view.post.map(Post1Snapshot.init),
            community: .init(from: community),
            removed: view.modRemovePost.removed,
            reason: view.modRemovePost.reason
        )
    }
    
    init(from view: PieFedModLockPostView) throws(ApiClientError) {
        guard let community = view.community else {
            throw ApiClientError.responseMissingRequiredData("PieFedModLockPostView community")
        }
        self = try .lockPost(
            view.post.map(Post1Snapshot.init),
            community: .init(from: community),
            locked: view.modLockPost.locked
        )
    }
    
    init(from view: PieFedModFeaturePostView) throws(ApiClientError) {
        guard let community = view.community else {
            throw ApiClientError.responseMissingRequiredData("PieFedModFeaturePostView community")
        }
        self = try .pinPost(
            view.post.map(Post1Snapshot.init),
            community: .init(from: community),
            pinned: view.modFeaturePost.featured,
            type: view.modFeaturePost.isFeaturedCommunity ? .community : .instance
        )
    }
    
    init(from view: PieFedAdminPurgePostView) throws(ApiClientError) {
        self = .purgePost(reason: view.adminPurgePost.reason)
    }
    
    init(from view: PieFedModRemoveCommentView) throws(ApiClientError) {
        self = try .removeComment(
            view.comment.map(Comment1Snapshot.init),
            creator: view.commenter.map { person throws(ApiClientError) in
                try .init(from: person)
            },
            post: view.post.map(Post1Snapshot.init),
            community: view.community.map { community throws(ApiClientError) in
                try .init(from: community)
            },
            removed: view.modRemoveComment.removed,
            reason: view.modRemoveComment.reason
        )
    }
    
    init(from view: PieFedAdminPurgeCommentView) throws(ApiClientError) {
        self = .purgeComment(reason: view.adminPurgeComment.reason)
    }
    
    init(from view: PieFedModRemoveCommunityView) throws(ApiClientError) {
        self = try .removeCommunity(
            view.community.map { community throws(ApiClientError) in
                try .init(from: community)
            },
            removed: view.modRemoveCommunity.removed,
            reason: view.modRemoveCommunity.reason
        )
    }
    
    init(from view: PieFedAdminPurgeCommunityView) throws(ApiClientError) {
        self = .purgeCommunity(reason: view.adminPurgeCommunity.reason)
    }
    
    init(from view: PieFedModHideCommunityView) throws(ApiClientError) {
        self = try .hideCommunity(
            .init(from: view.community),
            hidden: view.modHideCommunity.hidden,
            reason: view.modHideCommunity.reason
        )
    }
    
    init(from view: PieFedModTransferCommunityView) throws(ApiClientError) {
        guard let moddedPerson = view.moddedPerson else {
            throw ApiClientError.responseMissingRequiredData("PieFedModTransferCommunityView bassedPerson")
        }
        self = try .transferCommunityOwnership(
            person: .init(from: moddedPerson),
            community: .init(from: view.community)
        )
    }
    
    init(from view: PieFedModAddCommunityView) throws(ApiClientError) {
        guard let moddedPerson = view.moddedPerson else {
            throw ApiClientError.responseMissingRequiredData("PieFedModAddCommunityView bassedPerson")
        }
        guard let community = view.community else {
            throw ApiClientError.responseMissingRequiredData("PieFedModAddCommunityView community")
        }
        self = try .updatePersonModeratorStatus(
            person: .init(from: moddedPerson),
            community: .init(from: community),
            appointed: !view.modAddCommunity.removed
        )
    }
    
    init(from view: PieFedModAddView) throws(ApiClientError) {
        guard let moddedPerson = view.moddedPerson else {
            throw ApiClientError.responseMissingRequiredData("PieFedModAddView moddedPerson")
        }
        self = try .updatePersonAdminStatus(
            person: .init(from: moddedPerson),
            appointed: !view.modAdd.removed
        )
    }
    
    init(from view: PieFedModBanFromCommunityView) throws(ApiClientError) {
        guard let bannedPerson = view.bannedPerson else {
            throw ApiClientError.responseMissingRequiredData("PieFedModBanFromCommunityView bannedPerson")
        }
        guard let community = view.community else {
            throw ApiClientError.responseMissingRequiredData("PieFedModBanFromCommunityView community")
        }
        self = try .banPersonFromCommunity(
            person: .init(from: bannedPerson),
            community: .init(from: community),
            banned: view.modBanFromCommunity.banned,
            reason: view.modBanFromCommunity.reason,
            expires: view.modBanFromCommunity.expires
        )
    }
    
    init(from view: PieFedModBanView) throws(ApiClientError) {
        guard let bannedPerson = view.bannedPerson else {
            throw ApiClientError.responseMissingRequiredData("PieFedModBanView bannedPerson")
        }
        self = try .banPersonFromInstance(
            person: .init(from: bannedPerson),
            banned: view.modBan.banned,
            reason: view.modBan.reason,
            expires: view.modBan.expires
        )
    }
    
    init(from view: PieFedAdminPurgePersonView) throws(ApiClientError) {
        self = .purgePerson(reason: view.adminPurgePerson.reason)
    }
}
