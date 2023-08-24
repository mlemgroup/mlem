//
//  All Items Feed View.swift
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
            if allItems.isEmpty, isLoading {
                LoadingView(whatIsLoading: .inbox)
            } else if allItems.isEmpty {
                noItemsView()
            } else {
                LazyVStack(spacing: 0) {
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
        ForEach(allItems) { item in
            VStack(spacing: 0) {
                Group {
                    switch item.type {
                    case let .mention(mention):
                        inboxMentionViewWithInteraction(mention: mention)
                    case let .message(message):
                        inboxMessageViewWithInteraction(message: message)
                    case let .reply(reply):
                        inboxReplyViewWithInteraction(reply: reply)
                    }
                }
                
                Divider()
            }
        }
    }
}
