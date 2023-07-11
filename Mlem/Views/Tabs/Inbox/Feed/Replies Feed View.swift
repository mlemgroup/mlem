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
            Image(systemName: "text.bubble")
            
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
        NavigationLink(value: LazyLoadPostLinkWithContext(post: reply.post, postTracker: dummyPostTracker)) {
            InboxReplyView(reply: reply, menuFunctions: genCommentReplyMenuGroup(commentReply: reply))
                .padding(.vertical, AppConstants.postAndCommentSpacing)
                .padding(.horizontal)
                .background(Color.systemBackground)
                .task {
                    if repliesTracker.shouldLoadContent(after: reply) {
                        await loadTrackerPage(tracker: repliesTracker)
                    }
                }
                .contextMenu {
                    ForEach(genCommentReplyMenuGroup(commentReply: reply)) { item in
                        Button {
                            item.callback()
                        } label: {
                            Label(item.text, systemImage: item.imageName)
                        }
                    }
                }
                .addSwipeyActions(isDragging: $isDragging,
                                  primaryLeadingAction: upvoteCommentReplySwipeAction(commentReply: reply),
                                  secondaryLeadingAction: downvoteCommentReplySwipeAction(commentReply: reply),
                                  primaryTrailingAction: toggleCommentReplyReadSwipeAction(commentReply: reply),
                                  secondaryTrailingAction: replyToCommentReplySwipeAction(commentReply: reply))
        }
        .buttonStyle(EmptyButtonStyle())
    }
}
