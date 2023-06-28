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
            if mentionsTracker.mentions.isEmpty {
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
        if mentionsTracker.isLoading {
            LoadingView(whatIsLoading: .mentions)
        } else {
            VStack(alignment: .center, spacing: 5) {
                Image(systemName: "text.bubble")

                Text("No mentions to be found")
            }
            .padding()
            .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    func mentionsListView() -> some View {
        ForEach(mentionsTracker.mentions) { mention in
            VStack(spacing: spacing) {
                InboxMentionView(account: account, mention: mention)
                    .task {
                        if !mentionsTracker.isLoading && mention.personMention.id == mentionsTracker.loadMarkId {
                            await loadMentions()
                        }
                    }
                    .padding(.horizontal)
                Divider()
            }
        }
    }
}
