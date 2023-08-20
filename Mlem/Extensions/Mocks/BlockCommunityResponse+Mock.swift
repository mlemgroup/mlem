// 
//  BlockCommunityResponse+Mock.swift
//  Mlem
//
//  Created by mormaer on 20/08/2023.
//  
//

import Foundation

extension BlockCommunityResponse {
    static func mock(
        communityView: APICommunityView = .mock(),
        blocked: Bool = false
    ) -> BlockCommunityResponse {
        .init(
            communityView: communityView,
            blocked: blocked
        )
    }
}
