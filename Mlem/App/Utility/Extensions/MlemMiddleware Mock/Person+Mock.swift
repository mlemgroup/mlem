//
//  Person1+Mock.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-02.
//

import Foundation
import MlemMiddleware

extension Person1 {
    static func mock(_ type: PersonMockType) -> Person1 {
        .mock(
            actorId: type.actorId,
            id: 0,
            name: type.name,
            created: type.created,
            instanceId: 0,
            updated: nil,
            displayName: type.displayName,
            description: type.description,
            matrixId: type.matrixId,
            avatar: type.avatar,
            banner: type.banner,
            deleted: false,
            isBot: type.isBot,
            instanceBan: .notBanned,
            blocked: false
        )
    }
}

extension Person2 {
    static func mock(
        _ type: PersonMockType,
        isAdmin: Bool = false
    ) -> Person2 {
        .mock(
            person1: .mock(type),
            postCount: type.postCount,
            commentCount: type.commentCount,
            isAdmin: isAdmin
        )
    }
}
