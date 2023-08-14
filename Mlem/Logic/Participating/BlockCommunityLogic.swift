//
//  BlockCommunityLogic.swift
//  Mlem
//
//  Created by Ben Baron on 8/14/23.
//

import Foundation

@MainActor
func blockCommunity(
    account: SavedAccount,
    community: APICommunity,
    blocked: Bool) async throws -> Bool {
        let request = BlockCommunityRequest(
            account: account,
            communityId: community.id,
            block: blocked
        )
        let response = try await APIClient().perform(request: request)
        HapticManager.shared.play(haptic: .violentSuccess, priority: .high)
        return response.blocked
    }
