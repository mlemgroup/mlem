//
//  ModlogEntryContentSnapshot.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-13.
//

import Foundation

public enum ModlogEntryContentSnapshot {
    case removePost(
        _ post: Post1Snapshot?,
        community: Community1Snapshot,
        removed: Bool,
        reason: String?
    )
    case lockPost(
        _ post: Post1Snapshot?,
        community: Community1Snapshot,
        locked: Bool
    )
    case pinPost(
        _ post: Post1Snapshot?,
        community: Community1Snapshot,
        pinned: Bool,
        type: PostFeatureType
    )
    case purgePost(reason: String?)
    
    case removeComment(
        _ comment: Comment1Snapshot?,
        creator: Person1Snapshot?,
        post: Post1Snapshot?,
        community: Community1Snapshot?,
        removed: Bool,
        reason: String?
    )
    case purgeComment(reason: String?)
    
    case removeCommunity(
        _ community: Community1Snapshot?,
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
        person: Person1Snapshot?,
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
}
