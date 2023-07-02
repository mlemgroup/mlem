//
//  MentionsFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation
import SwiftUI

extension InboxView {
    @ViewBuilder
    func mentionsFeedView() -> some View {
        Group {
            if mentionsTracker.items.isEmpty && !mentionsTracker.isLoading {
                noMentionsView()
            } else {
                LazyVStack(spacing: AppConstants.postAndCommentSpacing) {
                    mentionsListView()
                    
                    if mentionsTracker.isLoading {
                        LoadingView(whatIsLoading: .mentions)
                    } else {
                        // this isn't just cute--if it's not here we get weird bouncing behavior if we get here, load, and then there's nothing
                        Text("That's all!").foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func noMentionsView() -> some View {
        VStack(alignment: .center, spacing: 5) {
            Image(systemName: "text.bubble")
            
            Text("No mentions to be found")
        }
        .padding()
        .foregroundColor(.secondary)
    }
    
    @ViewBuilder
    func mentionsListView() -> some View {
        ForEach(mentionsTracker.items) { mention in
            VStack(spacing: AppConstants.postAndCommentSpacing) {
                InboxMentionView(account: account, mention: mention)
                    .task {
                        if mentionsTracker.shouldLoadContent(after: mention) {
                            await loadTrackerPage(tracker: mentionsTracker)
                        }
                    }
                    .padding(.horizontal)
                Divider()
            }
        }
    }
}
