//
//  Post Post.swift
//  Mlem
//
//  Created by David Bureš on 22.05.2023.
//

import Foundation
import SwiftUI

// TODO: give this a home so it's not a globally scoped function
// TODO: consider a small struct to hold the post information as oppossed to individual arguments?
// swiftlint:disable function_parameter_count
func postPost(
    to community: APICommunity,
    postTitle: String,
    postBody: String,
    postURL: String?,
    postIsNSFW: Bool,
    postTracker: PostTracker,
    account: SavedAccount) async throws {
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
            postTracker.prepend(response.postView)
        }
    }
}
// swiftlint:enable function_parameter_count
