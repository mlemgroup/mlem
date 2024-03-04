//
//  APIClient+Community.swift
//  Mlem
//
//  Created by mormaer on 26/07/2023.
//
//

import Foundation

extension APIClient {
    func loadCommunityList(
        sort: String?,
        page: Int?,
        limit: Int?,
        type: String
    ) async throws -> ListCommunityResponse {
        let request = try ListCommunitiesRequest(
            session: session,
            sort: sort,
            page: page,
            limit: limit,
            type: type
        )
        
        return try await perform(request: request)
    }
    
    func loadCommunityDetails(id: Int) async throws -> GetCommunityResponse {
        let request = try GetCommunityRequest(session: session, communityId: id)
        return try await perform(request: request)
    }
    
    @discardableResult
    func followCommunity(id: Int, shouldFollow: Bool) async throws -> CommunityResponse {
        let request = try FollowCommunityRequest(session: session, communityId: id, follow: shouldFollow)
        return try await perform(request: request)
    }
    
    func hideCommunity(id: Int, shouldHide: Bool, reason: String?) async throws -> CommunityResponse {
        let request = try HideCommunityRequest(
            session: session,
            communityId: id,
            hidden: shouldHide,
            reason: reason
        )
        
        return try await perform(request: request)
    }
    
    func blockCommunity(id: Int, shouldBlock: Bool) async throws -> BlockCommunityResponse {
        let request = try BlockCommunityRequest(
            session: session,
            communityId: id,
            block: shouldBlock
        )
        
        return try await perform(request: request)
    }
    
    /// Bans the given user from the given community, provided the current user has permissions to do so
    /// - Parameters:
    ///   - userId: id of the user to ban
    ///   - communityId: id of the community to ban the user from
    ///   - ban: true if user should be banned, false if unbanned
    ///   - removeData: true if user data should be removed from community, false or nil otherwise
    ///   - reason: reason for ban
    ///   - expires: expiration date of ban (unit???)
    /// - Returns: updated ban status of user (true if banned, false otherwise)
    func banFromCommunity(
        userId: Int,
        communityId: Int,
        ban: Bool,
        removeData: Bool? = nil,
        reason: String? = nil,
        expires: Int? = nil
    ) async throws -> Bool {
        let request = try BanFromCommunityRequest(
            session: session,
            communityId: communityId,
            personId: userId,
            ban: ban,
            removeData: removeData,
            reason: reason,
            expires: expires
        )
            
        let response = try await perform(request: request)
            
        return response.banned
    }
    
    /// Adds or removes the given user from the mod list of the given community
    /// - Parameters:
    ///   - of: id of user to add/remove
    ///   - in: id of the community to add/remove to/from
    ///   - status: whether to add (true) or remove (false)
    /// - Returns: new list of moderators
    /// - Throws: error upon failed update
    func updateModStatus(of userId: Int, in communityId: Int, status: Bool) async throws -> [UserModel] {
        // perform update
        let request = try AddModToCommunityRequest(
            session: session,
            communityId: communityId,
            personId: userId,
            added: status
        )
        print(request)
        let response = try await perform(request: request)
        
        // validate response
        let isMod = response.moderators.contains(where: { $0.moderator.id == userId })
        if isMod != status {
            throw ContextualError(title: "Failed to add mod", underlyingError: APIClientError.unexpectedResponse)
        }
        
        // return new mod list
        return response.moderators.map { UserModel(from: $0.moderator) }
    }
}
