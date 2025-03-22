//
//  Person1+Codable.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-01-03.
//

import Foundation

public extension Person1 {
    struct CodedData: Codable {
        let apiUrl: URL
        let apiMyPersonId: Int?
        let apiPerson: ApiPerson
    }
    
    internal var apiPerson: ApiPerson {
        .init(
            id: id,
            name: name,
            displayName: displayName == name ? nil : displayName,
            avatar: avatar,
            banned: bannedFromInstance,
            published: created,
            updated: updated,
            actorId: actorId,
            bio: description,
            local: apiIsLocal,
            banner: banner,
            deleted: deleted,
            matrixUserId: matrixId,
            admin: nil,
            botAccount: isBot,
            banExpires: instanceBan.expiryDate,
            instanceId: instanceId,
            inboxUrl: nil
        )
    }
    
    func codedData() async throws -> CodedData {
        try await .init(
            apiUrl: api.baseUrl,
            apiMyPersonId: api.myPersonId,
            apiPerson: apiPerson
        )
    }
}
