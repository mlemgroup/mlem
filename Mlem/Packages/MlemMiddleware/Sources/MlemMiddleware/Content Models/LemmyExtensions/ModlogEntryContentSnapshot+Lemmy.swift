//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-09-28.
//

import Foundation

// MARK: Lemmy 1.0

extension ModlogEntryContentSnapshot {
    init?(from view: LemmyModlogView) throws(ApiClientError) {
        let value: Self? = switch view.modlog.kind {
        case .modRemovePost:
            // Temporarily disabled, see #2558
            // try Self.modRemovePost(view: view)
            nil
        case .modLockPost:
            try Self.modLockPost(view: view)
        case .modRemoveComment:
            // Temporarily disabled, see #2558
            // try Self.modRemoveComment(view: view)
            nil
        case .modBanFromCommunity:
            try Self.modBanFromCommunity(view: view)
        case .modTransferCommunity:
            try Self.modTransferCommunity(view: view)
        case .adminPurgePerson:
            try Self.adminPurgePerson(view: view)
        case .adminPurgeCommunity:
            try Self.adminPurgeCommunity(view: view)
        case .adminPurgePost:
            try Self.adminPurgePost(view: view)
        case .adminPurgeComment:
            try Self.adminPurgeComment(view: view)
        case .adminAdd:
            try Self.adminAdd(view: view)
        case .adminBan:
            try Self.adminBan(view: view)
        case .modAddToCommunity:
            try Self.modAddToCommunity(view: view)
        case .adminFeaturePostSite:
            try Self.adminFeaturePostSite(view: view)
        case .modFeaturePostCommunity:
            try Self.modFeaturePostCommunity(view: view)
        case .adminRemoveCommunity:
            try Self.adminRemoveCommunity(view: view)

        // These cases will not appear on Lemmy 1.0 

        case .modFeaturePost, // Renamed to `.modFeaturePostCommunity`
        .modRemoveCommunity, // Renamed to `.adminRemoveCommunity`
        .modAddCommunity, // Renamed to `.modAddToCommunity`
        .modAdd, // Renamed to `.adminAdd`
        .modBan, // Renamed to `.adminBan`
        .modHideCommunity, // Superceded by `.modChangeCommunityVisibility`
        .all:
            throw ApiClientError.featureUnsupported

        // These cases are new in Lemmy 1.0, and do not yet have matching ModlogEntryContentSnapshot cases.
        // Return `nil` rather than throwing so that the Modlog can still load. These cases will just be hidden.

        case .adminAllowInstance, .adminBlockInstance, .modChangeCommunityVisibility,
             .modLockComment, .modWarnPost, .modWarnComment:
           nil
        }

        if let value {
            self = value
        } else {
            return nil
        }
    }

    private static func modRemovePost(view: LemmyModlogView) throws(ApiClientError) -> Self {
        assert(view.modlog.kind == .modRemovePost)
        guard let post = view.targetPost, let community = view.targetCommunity else {
            throw ApiClientError.responseMissingRequiredData("modRemovePost target")
        }
        return .removePost(
            try .init(from: post),
            community: try .init(from: community),
            removed: !view.modlog.isRevert,
            reason: view.modlog.reason
        )
    }

    private static func modLockPost(view: LemmyModlogView) throws(ApiClientError) -> Self {
        assert(view.modlog.kind == .modLockPost)
        guard let post = view.targetPost, let community = view.targetCommunity else {
            throw ApiClientError.responseMissingRequiredData("modLockPost target")
        }
        return try .lockPost(
            .init(from: post),
            community: .init(from: community),
            locked: !view.modlog.isRevert
        )
    }

    private static func modRemoveComment(view: LemmyModlogView) throws(ApiClientError) -> Self {
        assert(view.modlog.kind == .modRemoveComment)
        guard let comment = view.targetComment,
            let post = view.targetPost,
            let community = view.targetCommunity,
            let person = view.targetPerson else {
            throw ApiClientError.responseMissingRequiredData(
                "modRemoveComment \(view.targetPost == nil) \(view.targetComment == nil) \(view.targetPerson == nil)"
            )
        }
        return try .removeComment(
            .init(from: comment),
            creator: .init(from: person),
            post: .init(from: post),
            community: .init(from: community),
            removed: !view.modlog.isRevert,
            reason: view.modlog.reason
        )
    }

    private static func modBanFromCommunity(view: LemmyModlogView) throws(ApiClientError) -> Self {
        assert(view.modlog.kind == .modBanFromCommunity)
        guard let community = view.targetCommunity, let person = view.targetPerson else {
            throw ApiClientError.responseMissingRequiredData("modBanFromCommunity target")
        }
        return try .banPersonFromCommunity(
            person: .init(from: person),
            community: .init(from: community),
            banned: !view.modlog.isRevert,
            reason: view.modlog.reason,
            expires: view.modlog.expiresAt
        )
    }

    private static func modTransferCommunity(view: LemmyModlogView) throws(ApiClientError) -> Self {
        assert(view.modlog.kind == .modTransferCommunity)
        guard let community = view.targetCommunity, let person = view.targetPerson else {
            throw ApiClientError.responseMissingRequiredData("modTransferCommunity target")
        }
        return try .transferCommunityOwnership(
            person: .init(from: person),
            community: .init(from: community)
        )
    }

    private static func adminPurgePerson(view: LemmyModlogView) throws(ApiClientError) -> Self {
        assert(view.modlog.kind == .adminPurgePerson)
        return .purgePerson(reason: view.modlog.reason)
    }

    private static func adminPurgeCommunity(view: LemmyModlogView) throws(ApiClientError) -> Self {
        assert(view.modlog.kind == .adminPurgeCommunity)
        return .purgeCommunity(reason: view.modlog.reason)
    }

    private static func adminPurgePost(view: LemmyModlogView) throws(ApiClientError) -> Self {
        assert(view.modlog.kind == .adminPurgePost)
        return .purgePost(reason: view.modlog.reason)
    }

    private static func adminPurgeComment(view: LemmyModlogView) throws(ApiClientError) -> Self {
        assert(view.modlog.kind == .adminPurgeComment)
        return .purgeComment(reason: view.modlog.reason)
    }

    private static func adminAdd(view: LemmyModlogView) throws(ApiClientError) -> Self {
        assert(view.modlog.kind == .adminAdd)
        guard let person = view.targetPerson else {
            throw ApiClientError.responseMissingRequiredData("adminAdd target")
        }
        return try .updatePersonAdminStatus(
            person: .init(from: person),
            appointed: !view.modlog.isRevert
        )
    }

    private static func adminBan(view: LemmyModlogView) throws(ApiClientError) -> Self {
        assert(view.modlog.kind == .adminBan)
        guard let person = view.targetPerson else {
            throw ApiClientError.responseMissingRequiredData("adminBan target")
        }
        return try .banPersonFromInstance(
            person: .init(from: person),
            banned: !view.modlog.isRevert,
            reason: view.modlog.reason,
            expires: view.modlog.expiresAt
        )
    }

    private static func modAddToCommunity(view: LemmyModlogView) throws(ApiClientError) -> Self {
        assert(view.modlog.kind == .modAddToCommunity)
        guard let community = view.targetCommunity, let person = view.targetPerson else {
            throw ApiClientError.responseMissingRequiredData("modAddToCommunity target")
        }
        return try .updatePersonModeratorStatus(
            person: .init(from: person),
            community: .init(from: community),
            appointed: !view.modlog.isRevert
        )
    }

    private static func adminFeaturePostSite(view: LemmyModlogView) throws(ApiClientError) -> Self {
        assert(view.modlog.kind == .adminFeaturePostSite)
        guard let post = view.targetPost, let community = view.targetCommunity else {
            throw ApiClientError.responseMissingRequiredData("adminFeaturePostSite target")
        }
        return try .pinPost(
            .init(from: post),
            community: .init(from: community),
            pinned: !view.modlog.isRevert,
            type: .instance
        )
    }

    private static func modFeaturePostCommunity(view: LemmyModlogView) throws(ApiClientError) -> Self {
        assert(view.modlog.kind == .modFeaturePostCommunity)
        guard let post = view.targetPost, let community = view.targetCommunity else {
            throw ApiClientError.responseMissingRequiredData("modFeaturePostCommunity target")
        }
        return try .pinPost(
            .init(from: post),
            community: .init(from: community),
            pinned: !view.modlog.isRevert,
            type: .community
        )
    }

    private static func adminRemoveCommunity(view: LemmyModlogView) throws(ApiClientError) -> Self {
        assert(view.modlog.kind == .adminRemoveCommunity)
        guard let community = view.targetCommunity else {
            throw ApiClientError.responseMissingRequiredData("adminRemoveCommunity target")
        }
        return try .removeCommunity(
            .init(from: community),
            removed: !view.modlog.isRevert,
            reason: view.modlog.reason
        )
    }
}
    

// MARK: Lemmy 0.19

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
