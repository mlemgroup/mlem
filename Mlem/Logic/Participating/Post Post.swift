//
//  Post Post.swift
//  Mlem
//
//  Created by David Bureš on 22.05.2023.
//

import Foundation
import SwiftUI

func postPost(
    to community: APICommunity,
    postTitle: String,
    postBody: String,
    postURL: String?,
    postIsNSFW: Bool,
    postTracker: PostTracker,
    account: SavedAccount,
    appState: AppState
) async throws {
    let request = CreatePostRequest(
        account: account,
        communityId: community.id,
        name: postTitle,
        nsfw: postIsNSFW,
        body: postBody,
        url: postURL
    )
    
    let response = try await APIClient().perform(request: request)
    await MainActor.run {
        withAnimation {
            postTracker.posts.prepend(response.postView)
        }
    }
}
