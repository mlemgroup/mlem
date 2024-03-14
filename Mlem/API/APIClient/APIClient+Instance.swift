//
//  APIClient+Instance.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-11.
//

import Foundation

extension APIClient {
    func getModlog(
        for instance: URL? = nil,
        modPersonId: Int? = nil,
        communityId: Int? = nil,
        page: Int,
        limit: Int,
        type: APIModlogActionType? = nil,
        otherPersonId: Int? = nil
    ) async throws -> [ModlogEntry] {
        // TODO: params
        var useSession: APISession
        
        if let instance {
            useSession = .unauthenticated(instance.appending(path: "/api/v3"))
        } else {
            useSession = session
        }
        
        #if DEBUG
            if let host = instance?.host(), ["lemmy-alpha", "lemmy-beta", "lemmy-delta"].contains(host) {
                useSession = .unauthenticated(.init(string: "http://localhost:8536/api/v3")!)
            }
        #endif
      
        let request = try GetModlogRequest(
            session: useSession,
            modPersonId: nil,
            communityId: communityId,
            page: page,
            limit: limit,
            type_: type,
            otherPersonId: otherPersonId
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
        ret.append(contentsOf: response.hiddenCommunities.map { ModlogEntry(from: $0) })
        
        return ret.sorted(by: { $0.date > $1.date })
    }
}
