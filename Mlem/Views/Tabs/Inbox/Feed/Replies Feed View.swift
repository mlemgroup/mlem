//
//  Replies Feed View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation
import SwiftUI

extension InboxView {
    @ViewBuilder
    func repliesFeedView() -> some View {
        Group {
            if repliesTracker.items.isEmpty {
                if repliesTracker.isLoading {
                    LoadingView(whatIsLoading: .replies)
                } else {
                    noRepliesView()
                }
            } else {
                LazyVStack(spacing: 0) {
                    repliesListView()
                    
                    if repliesTracker.isLoading {
                        LoadingView(whatIsLoading: .replies)
                    } else {
                        // this isn't just cute--if it's not here we get weird bouncing behavior if we get here, load, and then there's nothing
                        Text("That's all!").foregroundColor(.secondary).padding(.vertical, AppConstants.postAndCommentSpacing)
                    }
                }
            }
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
        ForEach(repliesTracker.items) { reply in
            VStack(spacing: 0) {
                inboxReplyViewWithInteraction(reply: reply)

                Divider()
            }
        }
    }
    
    func inboxReplyViewWithInteraction(reply: APICommentReplyView) -> some View {
        NavigationLink(.lazyLoadPostLinkWithContext(.init(
            post: reply.post,
            scrollTarget: reply.comment.id
        ))) {
            InboxReplyView(reply: reply, menuFunctions: genCommentReplyMenuGroup(commentReply: reply))
                .padding(.vertical, AppConstants.postAndCommentSpacing)
                .padding(.horizontal)
                .background(Color.systemBackground)
                .task {
                    if repliesTracker.shouldLoadContent(after: reply) {
                        await loadTrackerPage(tracker: repliesTracker)
                    }
                }
                .destructiveConfirmation(
                    isPresentingConfirmDestructive: $isPresentingConfirmDestructive,
                    confirmationMenuFunction: confirmationMenuFunction
                )
                .addSwipeyActions(
                    leading: [
                        upvoteCommentReplySwipeAction(commentReply: reply),
                        downvoteCommentReplySwipeAction(commentReply: reply)
                    ],
                    trailing: [
                        toggleCommentReplyReadSwipeAction(commentReply: reply),
                        replyToCommentReplySwipeAction(commentReply: reply)
                    ]
                )
                .contextMenu {
                    ForEach(genCommentReplyMenuGroup(commentReply: reply)) { item in
                        MenuButton(menuFunction: item, confirmDestructive: confirmDestructive)
                    }
                }
        }
        .buttonStyle(EmptyButtonStyle())
    }
}
