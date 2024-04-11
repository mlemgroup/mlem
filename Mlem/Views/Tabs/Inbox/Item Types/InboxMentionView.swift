//
//  InboxMentionView.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-12-22.
//

import SwiftUI

struct InboxMentionView: View {
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var unreadTracker: UnreadTracker
    
    @ObservedObject var mention: MentionModel
    
    var body: some View {
        VStack(spacing: 0) {
            InboxMentionBodyView(mention: mention)
            InteractionBarView(context: .comment, widgets: enrichLayoutWidgets())
        }
        .background(Color(uiColor: .systemBackground))
        .contentShape(Rectangle())
        .addSwipeyActions(
            mention.swipeActions(
                unreadTracker: unreadTracker,
                editorTracker: editorTracker
            )
        )
        .contextMenu {
            ForEach(mention.menuFunctions(
                unreadTracker: unreadTracker,
                editorTracker: editorTracker
            )) { item in
                MenuButton(menuFunction: item, menuFunctionPopup: .constant(nil))
            }
        }
    }
    
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func enrichLayoutWidgets() -> [EnrichedLayoutWidget] {
        layoutWidgetTracker.groups.comment.compactMap { baseWidget in
            switch baseWidget {
            case .infoStack:
                return .infoStack(
                    colorizeVotes: false,
                    votes: mention.votes,
                    published: mention.published,
                    updated: mention.comment.updated,
                    commentCount: mention.numReplies,
                    unreadCommentCount: 0,
                    saved: mention.saved
                )
            case .upvote:
                return .upvote(myVote: mention.votes.myVote) {
                    await mention.toggleUpvote(unreadTracker: unreadTracker)
                }
            case .downvote:
                return .downvote(myVote: mention.votes.myVote) {
                    await mention.toggleDownvote(unreadTracker: unreadTracker)
                }
            case .save:
                return .save(saved: mention.saved) {
                    await mention.toggleSave(unreadTracker: unreadTracker)
                }
            case .reply:
                return .reply {
                    mention.reply(editorTracker: editorTracker, unreadTracker: unreadTracker)
                }
            case .share:
                if let shareUrl = URL(string: mention.comment.apId) {
                    return .share(shareUrl: shareUrl)
                }
                return nil
            case .upvoteCounter:
                return .upvoteCounter(votes: mention.votes) {
                    await mention.toggleDownvote(unreadTracker: unreadTracker)
                }
            case .downvoteCounter:
                return .downvoteCounter(votes: mention.votes) {
                    await mention.toggleDownvote(unreadTracker: unreadTracker)
                }
            case .scoreCounter:
                return .scoreCounter(votes: mention.votes) {
                    await mention.toggleUpvote(unreadTracker: unreadTracker)
                } downvote: {
                    await mention.toggleDownvote(unreadTracker: unreadTracker)
                }
            default:
                return nil
            }
        }
    }
}
