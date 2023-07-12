//
//  MentionsFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation
import SwiftUI

extension InboxView {
    @ViewBuilder
    func mentionsFeedView() -> some View {
        Group {
            if mentionsTracker.items.isEmpty && !mentionsTracker.isLoading {
                noMentionsView()
            } else {
                LazyVStack(spacing: 0) {
                    mentionsListView()
                    
                    if mentionsTracker.isLoading {
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
            Image(systemName: "text.bubble")
            
            Text("No mentions to be found")
        }
        .padding()
        .foregroundColor(.secondary)
    }
    
    @ViewBuilder
    func mentionsListView() -> some View {
        ForEach(mentionsTracker.items) { mention in
            VStack(spacing: 0) {
                inboxMentionViewWithInteraction(mention: mention)
                Divider()
            }
        }
    }
    
    func inboxMentionViewWithInteraction(mention: APIPersonMentionView) -> some View {
        NavigationLink(value: LazyLoadPostLinkWithContext(post: mention.post, postTracker: dummyPostTracker)) {
            InboxMentionView(mention: mention, menuFunctions: genMentionMenuGroup(mention: mention))
                .padding(.vertical, AppConstants.postAndCommentSpacing)
                .padding(.horizontal)
                .background(Color.systemBackground)
                .task {
                    if mentionsTracker.shouldLoadContent(after: mention) {
                        await loadTrackerPage(tracker: mentionsTracker)
                    }
                }
                .contextMenu {
                    ForEach(genMentionMenuGroup(mention: mention)) { item in
                        Button {
                            item.callback()
                        } label: {
                            Label(item.text, systemImage: item.imageName)
                        }
                    }
                }
                .addSwipeyActions(isDragging: $isDragging,
                                  primaryLeadingAction: upvoteMentionSwipeAction(mentionView: mention),
                                  secondaryLeadingAction: downvoteMentionSwipeAction(mentionView: mention),
                                  primaryTrailingAction: toggleMentionReadSwipeAction(mentionView: mention),
                                  secondaryTrailingAction: replyToMentionSwipeAction(mentionView: mention))
        }
        .buttonStyle(EmptyButtonStyle())
    }
}
