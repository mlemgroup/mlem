//
//  Get Community Details.swift
//  Mlem
//
//  Created by David Bureš on 09.05.2023.
//

import Foundation

func loadCommunityDetails(
    community: APICommunity,
    account: SavedAccount,
    appState: AppState
) async throws -> GetCommunityResponse {
    do {
        let request = GetCommunityRequest(account: account, communityId: community.id)
        return try await APIClient().perform(request: request)
    }
}
