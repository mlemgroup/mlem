//
//  ReportPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-15.
//

import Dependencies
import Foundation
import SwiftUI

struct ReportPost: ResponseEditorModel {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.hapticManager) var hapticManager
    
    var id: Int { post.id }
    let canUpload: Bool = false
    let modalName: String = "Report Post"
    let prefillContents: String? = nil
    let post: APIPostView
    
    func embeddedView() -> AnyView {
        AnyView(LargePost(postView: post, layoutMode: .constant(.maximize))
            .padding(.horizontal, AppConstants.postAndCommentSpacing))
    }
    
    func sendResponse(responseContents: String) async throws {
        do {
            try await apiClient.reportPost(id: post.post.id, reason: responseContents)
            hapticManager.play(haptic: .violentSuccess, priority: .high)
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            throw error
        }
    }
}
