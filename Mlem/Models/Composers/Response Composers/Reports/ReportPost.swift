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
    
    var id: Int { postModel.postId }
    let canUpload: Bool = false
    let modalName: String = "Report Post"
    let prefillContents: String? = nil
    let postModel: PostModel
    
    func embeddedView() -> AnyView {
        AnyView(LargePost(postModel: postModel, layoutMode: .constant(.maximize))
            .padding(.horizontal, AppConstants.postAndCommentSpacing))
    }
    
    func sendResponse(responseContents: String) async throws {
        do {
            try await apiClient.reportPost(id: postModel.postId, reason: responseContents)
            hapticManager.play(haptic: .violentSuccess, priority: .high)
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            throw error
        }
    }
}
