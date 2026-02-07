//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-09-28.
//

import Foundation

extension ModlogEntryContentSnapshot {
    init(from view: LemmyModlogView) throws(ApiClientError) {
        self = switch view.modlog.kind {
        default: .purgeComment(reason: "TEST")
        }
    }

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
        self = try .removeComment(
            .init(from: view.comment),
            creator: .init(from: view.commenter),
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
        self = try .removeCommunity(
            .init(from: view.community),
            removed: view.modRemoveCommunity.removed,
            reason: view.modRemoveCommunity.reason
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
        self = try .transferCommunityOwnership(
            person: .init(from: view.moddedPerson),
            community: .init(from: view.community)
        )
    }
    
    init(from view: LemmyModAddToCommunityView) throws(ApiClientError) {
        self = try .updatePersonModeratorStatus(
            person: .init(from: view.moddedPerson),
            community: .init(from: view.community),
            appointed: !view.modAddCommunity.removed
        )
    }
    
    init(from view: LemmyAdminAddView) throws(ApiClientError) {
        self = try .updatePersonAdminStatus(
            person: .init(from: view.moddedPerson),
            appointed: !view.modAdd.removed
        )
    }
    
    init(from view: LemmyModBanFromCommunityView) throws(ApiClientError) {
        self = try .banPersonFromCommunity(
            person: .init(from: view.bannedPerson),
            community: .init(from: view.community),
            banned: view.modBanFromCommunity.banned,
            reason: view.modBanFromCommunity.reason,
            expires: view.modBanFromCommunity.expires
        )
    }
    
    init(from view: LemmyAdminBanView) throws(ApiClientError) {
        self = try .banPersonFromInstance(
            person: .init(from: view.bannedPerson),
            banned: view.modBan.banned,
            reason: view.modBan.reason,
            expires: view.modBan.expires
        )
    }
    
    init(from view: LemmyAdminPurgePersonView) throws(ApiClientError) {
        self = .purgePerson(reason: view.adminPurgePerson.reason)
    }
}
