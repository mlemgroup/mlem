//
//  APIComment+Mock.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2023.
//

import Foundation

extension APIComment {
    static func mock(
        id: Int = 0,
        creatorId: Int = 0,
        postId: Int = 0,
        content: String = "Mock Comment",
        removed: Bool = false,
        deleted: Bool = false,
        published: Date = .mock,
        updated: Date? = nil,
        apId: String = "mock.apId",
        local: Bool = false,
        path: String = "",
        distinguished: Bool = false,
        languageId: Int = 0
    ) -> APIComment {
        .init(
            id: id,
            creatorId: creatorId,
            postId: postId,
            content: content,
            removed: removed,
            deleted: deleted,
            published: published,
            updated: updated,
            apId: apId,
            local: local,
            path: path,
            distinguished: distinguished,
            languageId: languageId
        )
    }
}
