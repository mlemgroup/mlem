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
            if messagesTracker.isLoading {
                LoadingView(whatIsLoading: .messages)
            } else if messagesTracker.messages.isEmpty {
                noMessagesView()
            } else {
                LazyVStack(spacing: spacing) {
                    messagesListView()
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
        ForEach(messagesTracker.messages) { message in
            VStack(spacing: spacing) {
                InboxMessageView(account: account, message: message)
                    .task {
                        if !messagesTracker.isLoading && message.id == messagesTracker.loadMarkId {
                            await loadMessages()
                        }
                    }
                    .padding(.horizontal)
                Divider()
            }
        }
    }
}
