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
        Group {
            if mentionTracker.items.isEmpty, mentionTracker.loadingState != .loading {
                noMentionsView()
            } else {
                LazyVStack(spacing: 0) {
                    mentionsListView()
                    
                    if mentionTracker.loadingState != .loading {
                        LoadingView(whatIsLoading: .mentions)
                    } else {
                        // this isn't just cute--if it's not here we get weird bouncing behavior if we get here, load, and then there's nothing
                        Text("That's all!").foregroundColor(.secondary).padding(.vertical, AppConstants.postAndCommentSpacing)
                    }
                }
            }
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
        ForEach(mentionTracker.items) { mention in
            VStack(spacing: 0) {
                InboxMentionView(mention: mention, menuFunctions: [])
                // inboxMentionViewWithInteraction(mention: mention)
                Divider()
            }
        }
    }
    
//    func inboxMentionViewWithInteraction(mention: MentionModel) -> some View {
//        NavigationLink(.lazyLoadPostLinkWithContext(.init(
//            post: mention.post,
//            scrollTarget: mention.comment.id
//        ))) {
//            InboxMentionView(mention: mention, menuFunctions: genMentionMenuGroup(mention: mention))
//                .padding(.vertical, AppConstants.postAndCommentSpacing)
//                .padding(.horizontal)
//                .background(Color.systemBackground)
//                .task {
//                    if mentionsTracker.shouldLoadContent(after: mention) {
//                        await loadTrackerPage(tracker: mentionsTracker)
//                    }
//                }
//                .addSwipeyActions(
//                    leading: [
//                        upvoteMentionSwipeAction(mentionView: mention),
//                        downvoteMentionSwipeAction(mentionView: mention)
//                    ],
//                    trailing: [
//                        toggleMentionReadSwipeAction(mentionView: mention),
//                        replyToMentionSwipeAction(mentionView: mention)
//                    ]
//                )
//                .contextMenu {
//                    ForEach(genMentionMenuGroup(mention: mention)) { item in
//                        MenuButton(menuFunction: item, confirmDestructive: confirmDestructive)
//                    }
//                }
//        }
//        .buttonStyle(EmptyButtonStyle())
//    }
}
