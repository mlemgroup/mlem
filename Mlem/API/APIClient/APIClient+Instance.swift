//
//  APIClient+Instance.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-11.
//

import Foundation

extension APIClient {
    func getModlog() async throws -> [ModlogEntry] {
        // TODO: params
        let request = try GetModlogRequest(
            session: session,
            modPersonId: nil,
            communityId: nil,
            page: nil,
            limit: nil,
            type_: nil,
            otherPersonId: nil
        )
        
        let response = try await perform(request: request)
        
        var ret: [ModlogEntry] = .init()
        ret.append(contentsOf: response.removedPosts.map { ModlogEntry(from: $0) })
        ret.append(contentsOf: response.lockedPosts.map { ModlogEntry(from: $0) })
        ret.append(contentsOf: response.featuredPosts.map { ModlogEntry(from: $0) })
        ret.append(contentsOf: response.removedComments.map { ModlogEntry(from: $0) })
        ret.append(contentsOf: response.removedCommunities.map { ModlogEntry(from: $0) })
        ret.append(contentsOf: response.bannedFromCommunity.map { ModlogEntry(from: $0) })
        ret.append(contentsOf: response.banned.map { ModlogEntry(from: $0) })
        ret.append(contentsOf: response.addedToCommunity.map { ModlogEntry(from: $0) })
        ret.append(contentsOf: response.transferredToCommunity.map { ModlogEntry(from: $0) })
        ret.append(contentsOf: response.added.map { ModlogEntry(from: $0) })
        ret.append(contentsOf: response.adminPurgedPersons.map { ModlogEntry(from: $0) })
        ret.append(contentsOf: response.adminPurgedCommunities.map { ModlogEntry(from: $0) })
        ret.append(contentsOf: response.adminPurgedPosts.map { ModlogEntry(from: $0) })
        ret.append(contentsOf: response.adminPurgedComments.map { ModlogEntry(from: $0) })
        
        return ret.sorted(by: { $0.date > $1.date })
    }
}
