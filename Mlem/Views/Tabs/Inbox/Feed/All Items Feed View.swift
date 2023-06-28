//
//  AllItemsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation
import SwiftUI

extension InboxView {
    @ViewBuilder
    func inboxFeedView() -> some View {
        Group {
            if allItems.isEmpty {
                noItemsView()
            } else {
                LazyVStack(spacing: spacing) {
                    inboxListView()
                }
            }
        }
        .task(priority: .userInitiated) {
            if mentionsTracker.mentions.isEmpty ||
                messagesTracker.messages.isEmpty ||
                repliesTracker.replies.isEmpty {
                print("Inbox tracker is empty")
                await refreshFeed()
            } else {
                print("Inbox tracker is not empty")
            }
        }
    }
    
    @ViewBuilder
    func noItemsView() -> some View {
        if isLoading {
            LoadingView(whatIsLoading: .inbox)
        } else {
            VStack(alignment: .center, spacing: 5) {
                Image(systemName: "text.bubble")
                
                Text("No items to be found")
            }
            .padding()
            .foregroundColor(.secondary)
        }
    }
    
    // NOTE: this view is sometimes a little bit tetchy, and will refuse to compile for literally no reason. If that happens, copy it,
    // delete it, recompile, paste it, and it should work. Go figure.
    @ViewBuilder
    func inboxListView() -> some View {
        ForEach(allItems) { item in
            VStack(spacing: spacing) {
                Group {
                    switch item.type {
                    case .mention(let mention):
                        InboxMentionView(account: account, mention: mention)
                            .task {
                                if !mentionsTracker.isLoading && item.id == mentionsTracker.loadMarkId {
                                    await loadMentions()
                                }
                            }
                    case .message(let message):
                        InboxMessageView(account: account, message: message)
                            .task {
                                if !messagesTracker.isLoading && item.id == messagesTracker.loadMarkId {
                                    await loadMessages()
                                }
                            }
                    case .reply(let reply):
                        InboxReplyView(account: account, reply: reply)
                            .task {
                                if !repliesTracker.isLoading && item.id == repliesTracker.loadMarkId {
                                    await loadReplies()
                                }
                            }
                    }
                }
                .padding(.horizontal)
                
                Divider()
            }
        }
    }
}
