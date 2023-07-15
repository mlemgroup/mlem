//
//  ReportPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-15.
//

import Foundation
import SwiftUI

struct ReportPost: Respondable {
    
    var id: Int { post.id }
    let appState: AppState
    let canUpload: Bool = false
    let modalName: String = "Report Post"
    let post: APIPostView
    
    func embeddedView() -> AnyView {
        return AnyView(LargePost(postView: post, isExpanded: true)
            .padding(.horizontal, AppConstants.postAndCommentSpacing))
    }
    
    func sendResponse(responseContents: String) async throws {
        _ = try await reportPost(postId: post.post.id, account: appState.currentActiveAccount, reason: responseContents)
    }
}
