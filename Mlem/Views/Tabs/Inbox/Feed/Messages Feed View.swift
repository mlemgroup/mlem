//
//  MessagesFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation
import SwiftUI

struct MessagesFeedView: View {
    @ObservedObject var messageTracker: MessageTracker
    
    var body: some View {
        Group {
            if messageTracker.items.isEmpty, messageTracker.loadingState != .loading {
                noMessagesView()
            } else {
                LazyVStack(spacing: 0) {
                    messagesListView()
                    
                    if messageTracker.loadingState == .loading {
                        LoadingView(whatIsLoading: .messages)
                    } else {
                        // this isn't just cute--if it's not here we get weird bouncing behavior if we get here, load, and then there's nothing
                        Text("That's all!").foregroundColor(.secondary).padding(.vertical, AppConstants.postAndCommentSpacing)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func noMessagesView() -> some View {
        VStack(alignment: .center, spacing: 5) {
            Image(systemName: Icons.noPosts)
            
            Text("No messages to be found")
        }
        .padding()
        .foregroundColor(.secondary)
    }
    
    @ViewBuilder
    func messagesListView() -> some View {
        ForEach(messageTracker.items) { message in
            VStack(spacing: 0) {
                InboxMessageView(message: message, menuFunctions: [])
                // inboxMessageViewWithInteraction(message: message)
                
                Divider()
            }
        }
    }
    
//    @ViewBuilder
//    func inboxMessageViewWithInteraction(message: APIPrivateMessageView) -> some View {
//        InboxMessageView(message: message, menuFunctions: genMessageMenuGroup(message: message))
//            .padding(.vertical, AppConstants.postAndCommentSpacing)
//            .padding(.horizontal)
//            .background(Color.systemBackground)
//            .task {
//                if messagesTracker.shouldLoadContent(after: message) {
//                    await loadTrackerPage(tracker: messagesTracker)
//                }
//            }
//            .addSwipeyActions(
//                leading: [],
//                trailing: [
//                    toggleMessageReadSwipeAction(message: message),
//                    replyToMessageSwipeAction(message: message)
//                ]
//            )
//            .contextMenu {
//                ForEach(genMessageMenuGroup(message: message)) { item in
//                    MenuButton(menuFunction: item, confirmDestructive: confirmDestructive)
//                }
//            }
//    }
}
