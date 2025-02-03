//
//  Post1+Mock.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-02.
//

import Foundation
import MlemMiddleware

extension Post1 {
    // swiftlint:disable line_length
    enum MockedPost {
        case loremIpsum
        
        var title: String {
            switch self {
            case .loremIpsum:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
            }
        }
        
        var content: String? {
            switch self {
            case .loremIpsum:
                "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
            }
        }
        
        var created: Date {
            switch self {
            case .loremIpsum: .now.addingTimeInterval(-60 * 60 * 5)
            }
        }
    }

    // swiftlint:enable line_length

    static func mock(
        _ type: MockedPost,
        deleted: Bool = false,
        pinnedCommunity: Bool = false,
        pinnedInstance: Bool = false,
        locked: Bool = false,
        nsfw: Bool = false,
        removed: Bool = false
    ) -> Post1 {
        .mock(
            id: 0,
            creatorId: 0,
            communityId: 0,
            created: type.created,
            title: type.title,
            content: type.content,
            linkUrl: nil,
            deleted: deleted,
            embed: nil,
            pinnedCommunity: pinnedCommunity,
            pinnedInstance: pinnedInstance,
            locked: locked,
            nsfw: nsfw,
            removed: removed,
            thumbnailUrl: nil,
            updated: nil,
            languageId: 0,
            altText: nil
        )
    }
}
