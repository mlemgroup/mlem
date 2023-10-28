//
//  Replies Feed View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation
import SwiftUI

struct RepliesFeedView: View {
    @ObservedObject var replyTracker: ReplyTracker
    
    var body: some View {
        Group {
            if replyTracker.items.isEmpty {
                if replyTracker.loadingState == .loading {
                    LoadingView(whatIsLoading: .replies)
                } else {
                    noRepliesView()
                }
            } else {
                LazyVStack(spacing: 0) {
                    repliesListView()
                    
                    if replyTracker.loadingState == .loading {
                        LoadingView(whatIsLoading: .replies)
                    } else {
                        // this isn't just cute--if it's not here we get weird bouncing behavior if we get here, load, and then there's nothing
                        Text("That's all!").foregroundColor(.secondary).padding(.vertical, AppConstants.postAndCommentSpacing)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func noRepliesView() -> some View {
        VStack(alignment: .center, spacing: 5) {
            Image(systemName: Icons.noPosts)
            
            Text("No replies to be found")
        }
        .padding()
        .foregroundColor(.secondary)
    }
    
    @ViewBuilder
    func repliesListView() -> some View {
        ForEach(replyTracker.items, id: \.uid) { reply in
            VStack(spacing: 0) {
                InboxReplyView(reply: reply)

                Divider()
            }
        }
    }
}
