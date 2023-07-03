//
//  ReplyToPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import SwiftUI

struct ReplyToFeedPost: ReplyTo {
    let post: APIPostView
    let account: SavedAccount
    let appState: AppState
    
    func embeddedView() -> AnyView {
        return AnyView(LargePost(postView: post, isExpanded: true)
            .padding(.horizontal))
    }
    
    func sendReply(commentContents: String) async throws {
        guard let account = appState.currentActiveAccount else {
            print("Cannot Submit, No Active Account")
            return
        }
        
        try await postCommentFromFeed(
            to: post,
            commentContents: commentContents,
            account: account,
            appState: appState)
    }
}
