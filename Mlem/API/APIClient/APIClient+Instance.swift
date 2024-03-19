//
//  APIClient+Instance.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-11.
//

import Foundation

extension APIClient {
    // swiftlint:disable:next function_body_length
    func getModlog(
        for instanceUrl: URL? = nil,
        modPersonId: Int? = nil,
        communityId: Int? = nil,
        page: Int,
        limit: Int,
        type: APIModlogActionType? = nil,
        otherPersonId: Int? = nil
    ) async throws -> [ModlogEntry] {
        var useSession: APISession
        
        if let instanceUrl {
            useSession = .unauthenticated(instanceUrl.appending(path: "/api/v3"))
        } else {
            useSession = session
        }
        
        #if DEBUG
            if let host = instanceUrl?.host(), ["lemmy-alpha", "lemmy-beta", "lemmy-delta"].contains(host) {
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
        
        func isAdmin(for actorId: URL?) -> Bool {
            // can only view admin actions if the logged in user is an admin and the modlog is sourced from their instance
            siteInformation.isAdmin && actorId?.host() == siteInformation.instance?.url.host()
        }
        
        func canViewRemovedPost(in community: APICommunity) -> Bool {
            siteInformation.isMod(communityActorId: community.actorId) ||
                isAdmin(for: community.actorId)
        }
        
        var ret: [ModlogEntry] = .init()
        ret.append(contentsOf: response.removedPosts.map { ModlogEntry(
            from: $0,
            canViewRemovedPost: canViewRemovedPost(in: $0.community)
        ) })
        ret.append(contentsOf: response.lockedPosts.map { ModlogEntry(from: $0) })
        ret.append(contentsOf: response.featuredPosts.map { ModlogEntry(from: $0) })
        ret.append(contentsOf: response.removedComments.map { ModlogEntry(from: $0) })
        ret.append(contentsOf: response.removedCommunities.map { ModlogEntry(
            from: $0,
            canViewRemovedCommunity: isAdmin(for: $0.community.actorId)
        ) })
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
