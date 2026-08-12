//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-13.
//

import Foundation

public enum ModlogEntryType: CaseIterable {
    case removePost
    case lockPost
    case pinPost
    case purgePost
    case removeComment
    case purgeComment
    case removeCommunity
    case purgeCommunity
    case hideCommunity
    case transferCommunityOwnership
    case updatePersonModeratorStatus
    case updatePersonAdminStatus
    case banPersonFromCommunity
    case banPersonFromInstance
    case purgePerson
}
