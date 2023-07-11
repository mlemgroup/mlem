//
//  Private Messages View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation
import SwiftUI

extension InboxView {
    @ViewBuilder
    func messagesFeedView() -> some View {
        Group {
            if messagesTracker.items.isEmpty && !messagesTracker.isLoading {
                noMessagesView()
            } else {
                LazyVStack(spacing: 0) {
                    messagesListView()
                    
                    if messagesTracker.isLoading {
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
            Image(systemName: "text.bubble")
            
            Text("No messages to be found")
        }
        .padding()
        .foregroundColor(.secondary)
    }
    
    @ViewBuilder
    func messagesListView() -> some View {
        ForEach(messagesTracker.items) { message in
            VStack(spacing: 0) {
                inboxMessageViewWithInteraction(message: message)
                
                Divider()
            }
        }
    }
    
    @ViewBuilder
    func inboxMessageViewWithInteraction(message: APIPrivateMessageView) -> some View {
        InboxMessageView(message: message, menuFunctions: genMessageMenuGroup(message: message))
            .padding(.vertical, AppConstants.postAndCommentSpacing)
            .padding(.horizontal)
            .background(Color.systemBackground)
            .task {
                if messagesTracker.shouldLoadContent(after: message) {
                    await loadTrackerPage(tracker: messagesTracker)
                }
            }
            .contextMenu {
                ForEach(genMessageMenuGroup(message: message)) { item in
                    Button {
                        item.callback()
                    } label: {
                        Label(item.text, systemImage: item.imageName)
                    }
                }
            }
            .addSwipeyActions(isDragging: $isDragging,
                              primaryLeadingAction: nil,
                              secondaryLeadingAction: nil,
                              primaryTrailingAction: toggleMessageReadSwipeAction(message: message),
                              secondaryTrailingAction: replyToMessageSwipeAction(message: message))
    }
}
