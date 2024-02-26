//
//  APISite+Mock.swift
//  Mlem
//
//  Created by mormaer on 20/08/2023.
//
//

import Foundation

extension APISite {
    static func mock(
        id: Int = 0,
        name: String = "Mock Site",
        sidebar: String? = "Lorem Ipsum",
        published: Date = .mock,
        icon: String? = nil,
        banner: String? = nil,
        description: String? = nil,
        actorId: String? = nil,
        lastRefreshedAt: Date = .mock,
        inboxUrl: String = "https://mock.site",
        publicKey: String = "",
        instanceId: Int = 0
    ) -> APISite {
        .init(
            id: id,
            name: name,
            sidebar: sidebar,
            published: published,
            icon: icon,
            banner: banner,
            description: description,
            actorId: actorId,
            lastRefreshedAt: lastRefreshedAt,
            inboxUrl: inboxUrl,
            publicKey: publicKey,
            instanceId: instanceId
        )
    }
}
