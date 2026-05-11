//
//  ModlogEntrySnapshot+PieFed.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-12.
//

import Foundation

extension ModlogEntrySnapshot {
    init(from view: PieFedModRemovePostView) throws(ApiClientError) {
        let moderator: Person1Snapshot?
        if let value = view.moderator {
            moderator = try Person1Snapshot(from: value, allPropertiesPresent: true)
        } else {
            moderator = nil
        }
        try self.init(
            created: view.modRemovePost.when_,
            moderator: moderator,
            type: .init(from: view)
        )
    }
    
    init(from view: PieFedModLockPostView) throws(ApiClientError) {
        let moderator: Person1Snapshot?
        if let value = view.moderator {
            moderator = try Person1Snapshot(from: value, allPropertiesPresent: true)
        } else {
            moderator = nil
        }
        try self.init(
            created: view.modLockPost.when_,
            moderator: moderator,
            type: .init(from: view)
        )
    }
    
    init(from view: PieFedModFeaturePostView) throws(ApiClientError) {
        let moderator: Person1Snapshot?
        if let value = view.moderator {
            moderator = try Person1Snapshot(from: value, allPropertiesPresent: true)
        } else {
            moderator = nil
        }
        try self.init(
            created: view.modFeaturePost.when_,
            moderator: moderator,
            type: .init(from: view)
        )
    }
    
    init(from view: PieFedAdminPurgePostView) throws(ApiClientError) {
        let moderator: Person1Snapshot?
        if let value = view.admin {
            moderator = try Person1Snapshot(from: value, allPropertiesPresent: true)
        } else {
            moderator = nil
        }
        try self.init(
            created: view.adminPurgePost.when_,
            moderator: moderator,
            type: .init(from: view)
        )
    }
    
    init(from view: PieFedModRemoveCommentView) throws(ApiClientError) {
        let moderator: Person1Snapshot?
        if let value = view.moderator {
            moderator = try Person1Snapshot(from: value, allPropertiesPresent: true)
        } else {
            moderator = nil
        }
        try self.init(
            created: view.modRemoveComment.when_,
            moderator: moderator,
            type: .init(from: view)
        )
    }
    
    init(from view: PieFedAdminPurgeCommentView) throws(ApiClientError) {
        let moderator: Person1Snapshot?
        if let value = view.admin {
            moderator = try Person1Snapshot(from: value, allPropertiesPresent: true)
        } else {
            moderator = nil
        }
        try self.init(
            created: view.adminPurgeComment.when_,
            moderator: moderator,
            type: .init(from: view)
        )
    }
    
    init(from view: PieFedModRemoveCommunityView) throws(ApiClientError) {
        let moderator: Person1Snapshot?
        if let value = view.moderator {
            moderator = try Person1Snapshot(from: value, allPropertiesPresent: true)
        } else {
            moderator = nil
        }
        try self.init(
            created: view.modRemoveCommunity.when_,
            moderator: moderator,
            type: .init(from: view)
        )
    }
    
    init(from view: PieFedAdminPurgeCommunityView) throws(ApiClientError) {
        let moderator: Person1Snapshot?
        if let value = view.admin {
            moderator = try Person1Snapshot(from: value, allPropertiesPresent: true)
        } else {
            moderator = nil
        }
        try self.init(
            created: view.adminPurgeCommunity.when_,
            moderator: moderator,
            type: .init(from: view)
        )
    }
    
    init(from view: PieFedModHideCommunityView) throws(ApiClientError) {
        let moderator: Person1Snapshot?
        if let value = view.admin {
            moderator = try Person1Snapshot(from: value, allPropertiesPresent: true)
        } else {
            moderator = nil
        }
        try self.init(
            created: view.modHideCommunity.when_,
            moderator: moderator,
            type: .init(from: view)
        )
    }
    
    init(from view: PieFedModTransferCommunityView) throws(ApiClientError) {
        let moderator: Person1Snapshot?
        if let value = view.moderator {
            moderator = try Person1Snapshot(from: value, allPropertiesPresent: true)
        } else {
            moderator = nil
        }
        try self.init(
            created: view.modTransferCommunity.when_,
            moderator: moderator,
            type: .init(from: view)
        )
    }
    
    init(from view: PieFedModAddCommunityView) throws(ApiClientError) {
        let moderator: Person1Snapshot?
        if let value = view.moderator {
            moderator = try Person1Snapshot(from: value, allPropertiesPresent: true)
        } else {
            moderator = nil
        }
        try self.init(
            created: view.modAddCommunity.when_,
            moderator: moderator,
            type: .init(from: view)
        )
    }
    
    init(from view: PieFedModAddView) throws(ApiClientError) {
        let moderator: Person1Snapshot?
        if let value = view.moderator {
            moderator = try Person1Snapshot(from: value, allPropertiesPresent: true)
        } else {
            moderator = nil
        }

        try self.init(
            created: view.modAdd.when_,
            moderator: moderator,
            type: .init(from: view)
        )
    }
    
    init(from view: PieFedModBanFromCommunityView) throws(ApiClientError) {
        let moderator: Person1Snapshot?
        if let value = view.moderator {
            moderator = try Person1Snapshot(from: value, allPropertiesPresent: true)
        } else {
            moderator = nil
        }

        try self.init(
            created: view.modBanFromCommunity.when_,
            moderator: moderator,
            type: .init(from: view)
        )
    }
    
    init(from view: PieFedModBanView) throws(ApiClientError) {
        let moderator: Person1Snapshot?
        if let value = view.moderator {
            moderator = try Person1Snapshot(from: value, allPropertiesPresent: true)
        } else {
            moderator = nil
        }

        try self.init(
            created: view.modBan.when_,
            moderator: moderator,
            type: .init(from: view)
        )
    }
    
    init(from view: PieFedAdminPurgePersonView) throws(ApiClientError) {
        let moderator: Person1Snapshot?
        if let value = view.admin {
            moderator = try Person1Snapshot(from: value, allPropertiesPresent: true)
        } else {
            moderator = nil
        }

        try self.init(
            created: view.adminPurgePerson.when_,
            moderator: moderator,
            type: .init(from: view)
        )
    }
}
