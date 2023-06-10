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
        sort: sortingType
    )
    
    do {
        
        let response = try await APIClient().perform(request: request)
        
        guard !response.posts.isEmpty else {
            return
        }
        
        await MainActor.run {
            postTracker.posts.append(contentsOf: response.posts)
            postTracker.page += 1
        }
    } catch {
        // appState.alertTitle = "Couldn't connect to Lemmy"
        // appState.alertMessage = "Your network conneciton is either not stable enough, or the Lemmy server you're connected to is overloaded.\nTry again later."
        // appState.isShowingAlert.toggle()
        throw error
    }
}
