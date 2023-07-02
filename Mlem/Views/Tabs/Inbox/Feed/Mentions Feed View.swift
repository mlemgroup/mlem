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
            if mentionsTracker.isLoading {
                LoadingView(whatIsLoading: .mentions)
            } else if mentionsTracker.items.isEmpty {
                noMentionsView()
            } else {
                LazyVStack(spacing: spacing) {
                    mentionsListView()
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
            VStack(spacing: spacing) {
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
