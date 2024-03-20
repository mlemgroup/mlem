//
//  Replies Feed View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation
import SwiftUI

struct RepliesFeedView: View {
    @ObservedObject var replyTracker: ReplyTracker
    
    var body: some View {
        if replyTracker.loadingState == .done, replyTracker.items.isEmpty {
            noRepliesView()
        } else {
            repliesListView()
        }
    }
    
    @ViewBuilder
    func noRepliesView() -> some View {
        VStack(alignment: .center, spacing: 5) {
            Image(systemName: Icons.noPosts)
            
            Text("No replies to be found")
        }
        .padding()
        .foregroundColor(.secondary)
    }
    
    @ViewBuilder
    func repliesListView() -> some View {
        ForEach(replyTracker.items, id: \.uid) { reply in
            VStack(spacing: 0) {
                InboxReplyView(reply: reply)
                    .onAppear {
                        replyTracker.loadIfThreshold(reply)
                    }

                Divider()
            }
        }
        
        EndOfFeedView(loadingState: replyTracker.loadingState, viewType: .cartoon)
    }
}
