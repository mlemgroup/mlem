//
//  Edit Post.swift
//  Mlem
//
//  Created by Sjmarf on 23/07/2023.
//

import SwiftUI

// swiftlint:disable function_parameter_count
@discardableResult func editPost(
    postId: Int,
    postTitle: String,
    postBody: String,
    postURL: String?,
    postIsNSFW: Bool,
    postTracker: PostTracker,
    
    account: SavedAccount) async throws -> APIPostView {
        let request = EditPostRequest(
            account: account,
            postId: postId,
            name: postTitle,
            url: URL(string: postURL!),
            body: postBody,
            nsfw: postIsNSFW,
            languageId: nil
        )
        
        let response = try await APIClient().perform(request: request)
        HapticManager.shared.success()
        
        await MainActor.run {
            postTracker.update(with: response.postView)
        }
        
        return response.postView
    }
// swiftlint:enable function_parameter_count
