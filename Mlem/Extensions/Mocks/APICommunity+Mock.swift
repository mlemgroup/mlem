// 
//  APICommunity+Mock.swift
//  Mlem
//
//  Created by mormaer on 20/08/2023.
//  
//

import Foundation

extension APICommunity {
    static func mock(
        id: Int = 0,
        name: String = "Mock Community",
        title: String = "Mock",
        description: String? = nil,
        published: Date = .mock,
        updated: Date? = nil,
        removed: Bool = false,
        deleted: Bool = false,
        nsfw: Bool = false,
        actorId: URL = .mock,
        local: Bool = false,
        icon: URL? = nil,
        banner: URL? = nil,
        hidden: Bool = false,
        postingRestrictedToMods: Bool = false,
        instanceId: Int = 0
    ) -> APICommunity {
        .init(
            id: id,
            name: name,
            title: title,
            description: description,
            published: published,
            updated: updated,
            removed: removed,
            deleted: deleted,
            nsfw: nsfw,
            actorId: actorId,
            local: local,
            icon: icon,
            banner: banner,
            hidden: hidden,
            postingRestrictedToMods: postingRestrictedToMods,
            instanceId: instanceId
        )
    }
}
