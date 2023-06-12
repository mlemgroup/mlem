//
//  Infinite loader.swift
//  Mlem
//
//  Created by David Bureš on 18.06.2022.
//

import Foundation
import SwiftUI

enum LoadingError {
    case shittyInternet
}

@MainActor
func loadInfiniteFeed(
    postTracker: PostTracker,
    appState: AppState,
    communityId: Int?,
    feedType: FeedType,
    sortingType: SortingOptions,
    account: SavedAccount
) async throws {
    print("Page counter value: \(postTracker.page)")
    let request = GetPostsRequest(
        account: account,
        communityId: communityId,
        page: postTracker.page,
        sort: sortingType,
        type: feedType
    )
    
    let response = try await APIClient().perform(request: request)
    
    guard !response.posts.isEmpty else {
        return
    }
    
    await MainActor.run {
        postTracker.posts.append(contentsOf: response.posts)
        postTracker.page += 1
    }
}
