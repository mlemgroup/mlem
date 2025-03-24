//
//  ApiGetModlogResponse+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-25.
//

import Foundation

extension ApiGetModlogResponse {
    var allEntries: [any ModlogEntryApiBacker] {
        // Compiler didn't like it when I used `a + b + c + d`
        var output: [any ModlogEntryApiBacker] = []
        output += removedPosts ?? []
        output += lockedPosts ?? []
        output += featuredPosts ?? []
        output += adminPurgedPosts ?? []
        output += removedComments ?? []
        output += adminPurgedComments ?? []
        output += removedCommunities ?? []
        output += adminPurgedCommunities ?? []
        output += hiddenCommunities ?? []
        output += transferredToCommunity ?? []
        output += addedToCommunity ?? []
        output += added ?? []
        output += bannedFromCommunity ?? []
        output += banned ?? []
        output += adminPurgedPersons ?? []
        // TODO: 0.20 support add items from the new `modlog` field
        return output
    }
    
    func getEntries(ofType type: ApiModlogActionType) -> [any ModlogEntryApiBacker] {
        switch type {
        case .all: allEntries
        case .modRemovePost: removedPosts ?? []
        case .modLockPost: lockedPosts ?? []
        case .modFeaturePost: featuredPosts ?? []
        case .modRemoveComment: removedComments ?? []
        case .modRemoveCommunity: removedCommunities ?? []
        case .modBanFromCommunity: bannedFromCommunity ?? []
        case .modAddCommunity: addedToCommunity ?? []
        case .modTransferCommunity: transferredToCommunity ?? []
        case .modAdd: added ?? []
        case .modBan: banned ?? []
        case .modHideCommunity: hiddenCommunities ?? []
        case .adminPurgePerson: adminPurgedPersons ?? []
        case .adminPurgeCommunity: adminPurgedCommunities ?? []
        case .adminPurgePost: adminPurgedPosts ?? []
        case .adminPurgeComment: adminPurgedComments ?? []
        default: []
        }
    }
}
