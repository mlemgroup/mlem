//
//  Save Post.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-19.
//

@MainActor
func sendSavePostRequest(account: SavedAccount,
                         postId: Int,
                         save: Bool,
                         postTracker: PostTracker
) async throws -> APIPostView {
    do {
        let request = SavePostRequest(account: account, postId: postId, save: save)

        HapticManager.shared.gentleSuccess()
        let response = try await APIClient().perform(request: request)

        postTracker.update(with: response.postView)

        return response.postView
    } catch {
        HapticManager.shared.error()
        throw error
    }
}
