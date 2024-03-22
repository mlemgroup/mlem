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
        if messageTracker.loadingState == .done, messageTracker.items.isEmpty {
            noMessagesView()
        } else {
            messagesListView()
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
        ForEach(messageTracker.items, id: \.uid) { message in
            VStack(spacing: 0) {
                InboxMessageView(message: message)
                    .onAppear {
                        messageTracker.loadIfThreshold(message)
                    }
                
                Divider()
            }
        }
        
        EndOfFeedView(loadingState: messageTracker.loadingState, viewType: .cartoon)
    }
}
