//
//  Replies Feed View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation
import SwiftUI

extension InboxView {
    @ViewBuilder
    func repliesFeedView() -> some View {
        Group {
            if repliesTracker.replies.isEmpty {
                noRepliesView()
            } else {
                LazyVStack(spacing: spacing) {
                    repliesListView()
                }
            }
        }
    }
    
    @ViewBuilder
    func noRepliesView() -> some View {
        if repliesTracker.isLoading {
            LoadingView(whatIsLoading: .replies)
        } else {
            VStack(alignment: .center, spacing: 5) {
                Image(systemName: "text.bubble")
                
                Text("No replies to be found")
            }
            .padding()
            .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    func repliesListView() -> some View {
        ForEach(repliesTracker.replies) { reply in
            VStack(spacing: spacing) {
                InboxReplyView(account: account, reply: reply)
                    .task {
                        if !repliesTracker.isLoading && reply.commentReply.id == repliesTracker.loadMarkId {
                            await loadReplies()
                        }
                    }
                    .padding(.horizontal)
                Divider()
            }
        }
    }
}
