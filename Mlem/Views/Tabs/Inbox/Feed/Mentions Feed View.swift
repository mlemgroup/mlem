//
//  Mentions Feed View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation
import SwiftUI

struct MentionsFeedView: View {
    @ObservedObject var mentionTracker: MentionTracker
    
    var body: some View {
        if mentionTracker.loadingState == .done, mentionTracker.items.isEmpty {
            noMentionsView()
        } else {
            mentionsListView()
        }
    }
    
    @ViewBuilder
    func noMentionsView() -> some View {
        VStack(alignment: .center, spacing: 5) {
            Image(systemName: Icons.noPosts)
            
            Text("No mentions to be found")
        }
        .padding()
        .foregroundColor(.secondary)
    }
    
    @ViewBuilder
    func mentionsListView() -> some View {
        ForEach(mentionTracker.items, id: \.uid) { mention in
            VStack(spacing: 0) {
                InboxMentionView(mention: mention)
                    .onAppear {
                        mentionTracker.loadIfThreshold(mention)
                    }
                
                Divider()
            }
        }
        
        EndOfFeedView(loadingState: mentionTracker.loadingState, viewType: .cartoon)
    }
}
