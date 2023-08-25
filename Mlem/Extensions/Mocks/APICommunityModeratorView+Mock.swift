//
//  APICommunityModeratorView+Mock.swift
//  Mlem
//
//  Created by mormaer on 20/08/2023.
//
//

import Foundation

extension APICommunityModeratorView {
    static func mock() -> APICommunityModeratorView {
        .init(
            community: .mock(),
            moderator: .mock()
        )
    }
}
