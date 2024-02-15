//
//  APICommunityModeratorView+Mock.swift
//  Mlem
//
//  Created by mormaer on 20/08/2023.
//
//

import Foundation

extension APICommunityModeratorView: Mockable {
    static var mock: APICommunityModeratorView {
        .init(
            community: .mock(),
            moderator: .mock()
        )
    }
}
