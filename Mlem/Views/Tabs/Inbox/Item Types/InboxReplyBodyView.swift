//
//  InboxReplyBodyView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-25.
//

import SwiftUI

struct InboxReplyBodyView: View {
    @ObservedObject var reply: ReplyModel
    @EnvironmentObject var inboxTracker: InboxTracker
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var unreadTracker: UnreadTracker
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    
    @Environment(\.layoutDirection) var layoutDirection
    
    var voteIconName: String { reply.votes.myVote == .downvote ? Icons.downvote : Icons.upvote }
    var iconName: String { reply.commentReply.read ? "arrowshape.turn.up.right" : "arrowshape.turn.up.right.fill" }
    
    var body: some View {
        NavigationLink(.lazyLoadPostLinkWithContext(.init(
            postId: reply.post.id,
            scrollTarget: reply.comment.id
        ))) {
            content
                .background(Color(uiColor: .systemBackground))
                .contentShape(Rectangle())
                .contextMenu {
                    ForEach(reply.menuFunctions(
                        unreadTracker: unreadTracker,
                        editorTracker: editorTracker
                    )) { item in
                        MenuButton(menuFunction: item, menuFunctionPopup: .constant(nil))
                    }
                }
        }
        .buttonStyle(EmptyButtonStyle())
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
                HStack(spacing: AppConstants.standardSpacing) {
                    UserLinkView(
                        user: reply.creator,
                        serverInstanceLocation: .bottom,
                        bannedFromCommunity: reply.commentCreatorBannedFromCommunity,
                        overrideShowAvatar: true
                    )
                    
                    Spacer()
                    
                    Image(systemName: iconName)
                        .foregroundColor(.accentColor)
                        .frame(width: AppConstants.largeAvatarSize)
                    
                    EllipsisMenu(
                        size: AppConstants.largeAvatarSize,
                        menuFunctions: reply.menuFunctions(unreadTracker: unreadTracker, editorTracker: editorTracker)
                    )
                }
                
                MarkdownView(text: reply.comment.content, isNsfw: false)
                    .font(.subheadline)
                
                EmbeddedPost(community: reply.community.community, post: reply.post, comment: reply.comment)
            }
            .padding(.top, AppConstants.standardSpacing)
            .padding(.horizontal, AppConstants.standardSpacing)
    
            InteractionBarView(context: .comment, widgets: enrichLayoutWidgets())
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
