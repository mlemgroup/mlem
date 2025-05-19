//
//  Community1+Codable.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-01-01.
//

import Foundation

public extension Community1 {
    struct CodedData: Codable {
        let apiUrl: URL
        let apiMyPersonId: Int?
        let apiCommunity: ApiCommunity
    }
    
    internal var apiCommunity: ApiCommunity {
        ApiCommunity(
            id: id,
            name: name,
            title: displayName,
            description: description,
            removed: removed,
            published: created,
            updated: updated,
            deleted: deleted,
            nsfw: nsfw,
            actorId: actorId,
            local: apiIsLocal,
            icon: avatar,
            banner: banner,
            hidden: hidden,
            postingRestrictedToMods: onlyModeratorsCanPost,
            instanceId: instanceId,
            visibility: visibility,
            sidebar: nil,
            apId: actorId,
            subscribers: nil,
            posts: nil,
            comments: nil,
            usersActiveDay: nil,
            usersActiveWeek: nil,
            usersActiveMonth: nil,
            usersActiveHalfYear: nil,
            subscribersLocal: nil,
            reportCount: nil,
            unresolvedReportCount: nil,
            localRemoved: nil
        )
    }
    
    func codedData() async throws -> CodedData {
        try await .init(
            apiUrl: api.baseUrl,
            apiMyPersonId: api.myPersonId,
            apiCommunity: apiCommunity
        )
    }
}
