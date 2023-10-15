//
//  AllInboxFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-28.
//
import Foundation
import SwiftUI

struct AllInboxFeedView: View {
    @ObservedObject var inboxTracker: ParentTracker<InboxItemNew>

    var body: some View {
        ForEach(inboxTracker.items) { item in
            VStack(spacing: 0) {
                inboxItemView(item)
                Divider()
            }
        }
    }
    
    @ViewBuilder
    func inboxItemView(_ item: InboxItemNew) -> some View {
        switch item {
        case let .mention(mention):
            Text("not yet!")
        // inboxMentionViewWithInteraction(mention: mention)
        case let .message(message):
            InboxMessageViewNew(message: message, menuFunctions: [])
        // inboxMessageViewWithInteraction(message: message)
        case let .reply(reply):
            InboxReplyViewNew(reply: reply, menuFunctions: [])
            // inboxReplyViewWithInteraction(reply: reply)
        }
    }
}
