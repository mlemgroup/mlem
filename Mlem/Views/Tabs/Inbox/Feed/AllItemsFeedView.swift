//
//  AllItemsFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation
import SwiftUI

struct AllItemsFeedView: View {
    @ObservedObject var inboxTracker: ParentTracker<InboxItem>
    @ObservedObject var messageTracker: MessageTracker
    
    var body: some View {
        Group {
            if inboxTracker.items.isEmpty, inboxTracker.loadingState == .loading {
                LoadingView(whatIsLoading: .inbox)
            } else if inboxTracker.items.isEmpty {
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
            Image(systemName: Icons.noPosts)
            
            Text("No items to be found")
        }
        .padding()
        .foregroundColor(.secondary)
    }
    
    // NOTE: this view is sometimes a little bit tetchy, and will refuse to compile for literally no reason. If that happens, copy it,
    // delete it, recompile, paste it, and it should work. Go figure.
    @ViewBuilder
    func inboxListView() -> some View {
        ForEach(inboxTracker.items, id: \.uid) { item in
            VStack(spacing: 0) {
                Group {
                    switch item {
                    case let .mention(mention):
                        InboxMentionView(mention: mention)
                    case let .message(message):
                        InboxMessageView(message: message)
                    case let .reply(reply):
                        InboxReplyView(reply: reply)
                    }
                }
                
                Divider()
            }
        }
    }
}
