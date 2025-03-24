//
//  ModlogEntryType.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-25.
//

import Foundation

public enum ModlogEntryType: Equatable {
    case removePost(
        _ post: Post1,
        community: Community1,
        removed: Bool,
        reason: String?
    )
    case lockPost(
        _ post: Post1,
        community: Community1,
        locked: Bool
    )
    case pinPost(
        _ post: Post1,
        community: Community1,
        pinned: Bool,
        type: ApiPostFeatureType
    )
    case purgePost(reason: String?)
    
    case removeComment(
        _ comment: Comment1,
        creator: Person1,
        post: Post1,
        community: Community1,
        removed: Bool,
        reason: String?
    )
    case purgeComment(reason: String?)
    
    case removeCommunity(
        _ community: Community1,
        removed: Bool,
        reason: String?
    )
    case purgeCommunity(reason: String?)
    case hideCommunity(
        _ community: Community1,
        hidden: Bool,
        reason: String?
    )
    case transferCommunityOwnership(
        person: Person1,
        community: Community1
    )
    
    case updatePersonModeratorStatus(
        person: Person1,
        community: Community1,
        appointed: Bool
    )
    case updatePersonAdminStatus(
        person: Person1,
        appointed: Bool
    )
    case banPersonFromCommunity(
        person: Person1,
        community: Community1,
        banned: Bool,
        reason: String?,
        expires: Date?
    )
    case banPersonFromInstance(
        person: Person1,
        banned: Bool,
        reason: String?,
        expires: Date?
    )
    case purgePerson(reason: String?)
    
    public var community: Community1? {
        switch self {
        case let .removePost(_, community, _, _): community
        case let .lockPost(_, community, _): community
        case let .pinPost(_, community, _, _): community
        case let .removeComment(_, _, _, community, _, _): community
        case let .removeCommunity(community, _, _): community
        case let .hideCommunity(community, _, _): community
        case let .transferCommunityOwnership(_, community): community
        case let .updatePersonModeratorStatus(_, community, _): community
        case let .banPersonFromCommunity(_, community, _, _, _): community
        default: nil
        }
    }
    
    public var type: ApiModlogActionType {
        switch self {
        case .removePost: .modRemovePost
        case .lockPost: .modLockPost
        case .pinPost: .modFeaturePost
        case .purgePost: .adminPurgePost
        case .removeComment: .modRemoveComment
        case .purgeComment: .adminPurgeComment
        case .removeCommunity: .modRemoveCommunity
        case .purgeCommunity: .adminPurgeCommunity
        case .hideCommunity: .modHideCommunity
        case .transferCommunityOwnership: .modTransferCommunity
        case .updatePersonModeratorStatus: .modAddCommunity
        case .updatePersonAdminStatus: .modAdd
        case .banPersonFromCommunity: .modBanFromCommunity
        case .banPersonFromInstance: .modBan
        case .purgePerson: .adminPurgePerson
        }
    }
}
