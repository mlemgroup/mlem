//
//  ModlogEntryContent.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-25.
//

import Foundation

public enum ModlogEntryContent: Equatable {
    case removePost(
        _ post: UnifiedPostModel,
        community: Community1,
        removed: Bool,
        reason: String?
    )
    case lockPost(
        _ post: UnifiedPostModel,
        community: Community1,
        locked: Bool
    )
    case pinPost(
        _ post: UnifiedPostModel,
        community: Community1,
        pinned: Bool,
        type: PostFeatureType
    )
    case purgePost(reason: String?)
    
    case removeComment(
        _ comment: Comment1,
        creator: Person1,
        post: UnifiedPostModel,
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
    
    public var type: ModlogEntryType {
        switch self {
        case .removePost: .removePost
        case .lockPost: .lockPost
        case .pinPost: .pinPost
        case .purgePost: .purgePost
        case .removeComment: .removeComment
        case .purgeComment: .purgeComment
        case .removeCommunity: .removeCommunity
        case .purgeCommunity: .purgeCommunity
        case .hideCommunity: .hideCommunity
        case .transferCommunityOwnership: .transferCommunityOwnership
        case .updatePersonModeratorStatus: .updatePersonModeratorStatus
        case .updatePersonAdminStatus: .updatePersonAdminStatus
        case .banPersonFromCommunity: .banPersonFromCommunity
        case .banPersonFromInstance: .banPersonFromInstance
        case .purgePerson: .purgePerson
        }
    }
    
    @MainActor
    init(from snapshot: ModlogEntryContentSnapshot, api: ApiClient) {
        switch snapshot {
        case let .removePost(post, community, removed, reason):
            self = .removePost(
                api.caches.post.getModel(api: api, from: .post1(post)),
                community: api.caches.community1.getModel(api: api, from: community),
                removed: removed,
                reason: reason
            )
        case let .lockPost(post, community, locked):
            self = .lockPost(
                api.caches.post.getModel(api: api, from: .post1(post)),
                community: api.caches.community1.getModel(api: api, from: community),
                locked: locked
            )
        case let .pinPost(post, community, pinned, type):
            self = .pinPost(
                api.caches.post.getModel(api: api, from: .post1(post)),
                community: api.caches.community1.getModel(api: api, from: community),
                pinned: pinned,
                type: type
            )
        case let .purgePost(reason):
            self = .purgePost(reason: reason)
        case let .removeComment(comment, creator, post, community, removed, reason):
            self = .removeComment(
                api.caches.comment1.getModel(api: api, from: comment),
                creator: api.caches.person1.getModel(api: api, from: creator),
                post: api.caches.post.getModel(api: api, from: .post1(post)),
                community: api.caches.community1.getModel(api: api, from: community),
                removed: removed,
                reason: reason
            )
        case let .purgeComment(reason):
            self = .purgeComment(reason: reason)
        case let .removeCommunity(community, removed, reason):
            self = .removeCommunity(
                api.caches.community1.getModel(api: api, from: community),
                removed: removed,
                reason: reason
            )
        case let .purgeCommunity(reason):
            self = .purgeCommunity(reason: reason)
        case let .hideCommunity(community, hidden, reason):
            self = .hideCommunity(
                api.caches.community1.getModel(api: api, from: community),
                hidden: hidden,
                reason: reason
            )
        case let .transferCommunityOwnership(person, community):
            self = .transferCommunityOwnership(
                person: api.caches.person1.getModel(api: api, from: person),
                community: api.caches.community1.getModel(api: api, from: community)
            )
        case let .updatePersonModeratorStatus(person, community, appointed):
            self = .updatePersonModeratorStatus(
                person: api.caches.person1.getModel(api: api, from: person),
                community: api.caches.community1.getModel(api: api, from: community),
                appointed: appointed
            )
        case let .updatePersonAdminStatus(person, appointed):
            self = .updatePersonAdminStatus(
                person: api.caches.person1.getModel(api: api, from: person),
                appointed: appointed
            )
        case let .banPersonFromCommunity(person, community, banned, reason, expires):
            self = .banPersonFromCommunity(
                person: api.caches.person1.getModel(api: api, from: person),
                community: api.caches.community1.getModel(api: api, from: community),
                banned: banned,
                reason: reason,
                expires: expires
            )
        case let .banPersonFromInstance(person, banned, reason, expires):
            self = .banPersonFromInstance(
                person: api.caches.person1.getModel(api: api, from: person),
                banned: banned,
                reason: reason,
                expires: expires
            )
        case let .purgePerson(reason):
            self = .purgePerson(reason: reason)
        }
    }
}
