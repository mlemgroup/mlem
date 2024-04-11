//
//  InboxReplyView.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-12-21.
//

import SwiftUI

struct InboxReplyView: View {
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var unreadTracker: UnreadTracker
    
    @ObservedObject var reply: ReplyModel

    var body: some View {
        VStack(spacing: 0) {
            InboxReplyBodyView(reply: reply)
            InteractionBarView(context: .comment, widgets: enrichLayoutWidgets())
        }
        .background(Color(uiColor: .systemBackground))
        .contentShape(Rectangle())
        .addSwipeyActions(
            reply.swipeActions(
                unreadTracker: unreadTracker,
                editorTracker: editorTracker
            )
        )
        .contextMenu {
            ForEach(reply.menuFunctions(
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
                    votes: reply.votes,
                    published: reply.published,
                    updated: reply.comment.updated,
                    commentCount: reply.numReplies,
                    unreadCommentCount: 0,
                    saved: reply.saved
                )
            case .upvote:
                return .upvote(myVote: reply.votes.myVote) {
                    await reply.toggleUpvote(unreadTracker: unreadTracker)
                }
            case .downvote:
                return .downvote(myVote: reply.votes.myVote) {
                    await reply.toggleDownvote(unreadTracker: unreadTracker)
                }
            case .save:
                return .save(saved: reply.saved) {
                    await reply.toggleSave(unreadTracker: unreadTracker)
                }
            case .reply:
                return .reply {
                    reply.reply(editorTracker: editorTracker, unreadTracker: unreadTracker)
                }
            case .share:
                if let shareUrl = URL(string: reply.comment.apId) {
                    return .share(shareUrl: shareUrl)
                }
                return nil
            case .upvoteCounter:
                return .upvoteCounter(votes: reply.votes) {
                    await reply.toggleUpvote(unreadTracker: unreadTracker)
                }
            case .downvoteCounter:
                return .downvoteCounter(votes: reply.votes) {
                    await reply.toggleDownvote(unreadTracker: unreadTracker)
                }
            case .scoreCounter:
                return .scoreCounter(votes: reply.votes) {
                    await reply.toggleUpvote(unreadTracker: unreadTracker)
                } downvote: {
                    await reply.toggleDownvote(unreadTracker: unreadTracker)
                }
            default:
                return nil
            }
        }
    }
}
