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
            if isLoading {
                LoadingView(whatIsLoading: .inbox)
            } else if allItems.isEmpty {
                noItemsView()
            } else {
                LazyVStack(spacing: spacing) {
                    inboxListView()
                }
            }
        }
    }
    
    @ViewBuilder
    func noItemsView() -> some View {
        VStack(alignment: .center, spacing: 5) {
            Image(systemName: "text.bubble")
            
            Text("No items to be found")
        }
        .padding()
        .foregroundColor(.secondary)
    }
    
    // NOTE: this view is sometimes a little bit tetchy, and will refuse to compile for literally no reason. If that happens, copy it,
    // delete it, recompile, paste it, and it should work. Go figure.
    @ViewBuilder
    func inboxListView() -> some View {
        ForEach(genItemsToRender()) { item in
            VStack(spacing: spacing) {
                Group {
                    switch item.type {
                    case .mention(let mention):
                        InboxMentionView(account: account, mention: mention)
                            .task {
                                if mentionsTracker.shouldLoadContent(after: mention) {
                                    await loadTrackerPage(tracker: mentionsTracker)
                                }
                            }
                    case .message(let message):
                        InboxMessageView(account: account, message: message)
                            .task {
                                if messagesTracker.shouldLoadContent(after: message) {
                                    await loadTrackerPage(tracker: messagesTracker)
                                }
                            }
                    case .reply(let reply):
                        InboxReplyView(account: account, reply: reply)
                            .task {
                                if repliesTracker.shouldLoadContent(after: reply) {
                                    await loadTrackerPage(tracker: repliesTracker)
                                }
                            }
                    }
                }
                .padding(.horizontal)
                
                Divider()
            }
        }
    }
    
    // TODO: no. just... no.
    func genItemsToRender() -> [InboxItem] {
        switch selectionSection {
        case 0:
            return allItems
        case 1:
            return allItems.filter { item in
                if case InboxItemType.reply = item.type { return true }
                return false
            }
        case 2:
            return allItems.filter { item in
                if case InboxItemType.mention = item.type { return true }
                return false
            }
        case 3:
            return allItems.filter { item in
                if case InboxItemType.message = item.type { return true }
                return false
            }
        default: return []
        }
    }
}
