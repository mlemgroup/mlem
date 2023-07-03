//
//  ReplyToPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import SwiftUI

struct ReplyToPost: ReplyToWithComment {
    @EnvironmentObject var appState: AppState
    
    let post: APIPostView
    let account: SavedAccount
    
    func embeddedView() -> any View {
        FeedPost(postView: post,
                 account: account,
                 showPostCreator: true,
                 showCommunity: true,
                 showInteractionBar: false,
                 enableSwipeActions: false,
                 isDragging: Binding.constant(false))
    }
    
    func sendReply(contents: String, tracker: FeedTracker<APICommentView>) async {
        do {
            guard let account = appState.currentActiveAccount else {
                print("Cannot Submit, No Active Account")
                return
            }
            
            try await postComment(
                to: post,
                commentContents: contents,
                commentTracker: tracker,
                account: account,
                appState: appState)
            
            print("Reply Successful")
        } catch {
            print("Something went wrong)")
        }
    }
}
