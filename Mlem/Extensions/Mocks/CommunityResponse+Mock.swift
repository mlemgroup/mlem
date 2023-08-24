//
//  CommunityResponse+Mock.swift
//  Mlem
//
//  Created by mormaer on 20/08/2023.
//
//

import Foundation

extension CommunityResponse {
    static func mock(
        communityView: APICommunityView = .mock(),
        discussionLanguages: [Int] = []
    ) -> CommunityResponse {
        .init(
            communityView: communityView,
            discussionLanguages: discussionLanguages
        )
    }
}
