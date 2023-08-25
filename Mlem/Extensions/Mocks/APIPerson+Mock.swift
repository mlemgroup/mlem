//
//  APIPerson+Mock.swift
//  Mlem
//
//  Created by mormaer on 20/08/2023.
//
//

import Foundation

extension APIPerson {
    static func mock(
        id: Int = 0,
        name: String = "Mock Person",
        displayName: String? = nil,
        avatar: URL? = nil,
        banned: Bool = false,
        published: Date = .mock,
        updated: Date? = nil,
        actorId: URL = .mock,
        bio: String? = nil,
        local: Bool = false,
        banner: URL? = nil,
        deleted: Bool = false,
        sharedInboxUrl: URL? = nil,
        matrixUserId: String? = nil,
        admin: Bool = false,
        botAccount: Bool = false,
        banExpires: Date? = nil,
        instanceId: Int = 0
    ) -> APIPerson {
        .init(
            id: id,
            name: name,
            displayName: displayName,
            avatar: avatar,
            banned: banned,
            published: published,
            updated: updated,
            actorId: actorId,
            bio: bio,
            local: local,
            banner: banner,
            deleted: deleted,
            sharedInboxUrl: sharedInboxUrl,
            matrixUserId: matrixUserId,
            admin: admin,
            botAccount: botAccount,
            banExpires: banExpires,
            instanceId: instanceId
        )
    }
}
