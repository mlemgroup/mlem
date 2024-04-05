//
//  InboxFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-01.
//

import Foundation
import SwiftUI

struct InboxFeedView<T: TrackerProtocol>: View where T.Item: InboxItem {
    @ObservedObject var tracker: T
    
    var body: some View {
        if tracker.loadingState == .done, tracker.items.isEmpty {
            noItemsView()
        } else {
            itemsListView()
        }
    }
    
    @ViewBuilder
    func itemsListView() -> some View {
        ForEach(tracker.items, id: \.uid) { item in
            VStack(spacing: 0) {
                inboxItemView(item: item.toAnyInboxItem())
                    .onAppear {
                        tracker.loadIfThreshold(item)
                    }
                
                Divider()
            }
        }
        
        EndOfFeedView(loadingState: tracker.loadingState, viewType: .cartoon)
    }
    
    @ViewBuilder
    func inboxItemView(item: AnyInboxItem) -> some View {
        Group {
            switch item {
            case let .message(message):
                InboxMessageView(message: message)
            case let .mention(mention):
                InboxMentionView(mention: mention)
            case let .reply(reply):
                InboxReplyView(reply: reply)
            case let .commentReport(commentReport):
                InboxCommentReportView(commentReport: commentReport)
            case let .postReport(postReport):
                InboxPostReportView(postReport: postReport)
            case let .messageReport(messageReport):
                InboxMessageReportView(messageReport: messageReport)
            case let .registrationApplication(application):
                InboxRegistrationApplicationView(application: application)
            }
        }
    }
    
    @ViewBuilder
    func noItemsView() -> some View {
        VStack(alignment: .center, spacing: 5) {
            Image(systemName: Icons.noPosts)
            
            Text("No items found")
        }
        .padding()
        .foregroundColor(.secondary)
    }
}
