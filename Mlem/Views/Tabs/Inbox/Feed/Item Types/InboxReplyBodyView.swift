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
                        bannedFromCommunity: reply.creatorBannedFromCommunity,
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
            
            InteractionBarView(
                votes: reply.votes,
                published: reply.published,
                updated: reply.comment.updated,
                commentCount: reply.numReplies,
                saved: reply.saved,
                accessibilityContext: "comment",
                widgets: layoutWidgetTracker.groups.comment,
                upvote: { assertionFailure("TODO: upvote") },
                downvote: { assertionFailure("TODO: downvote") },
                save: { assertionFailure("TODO: save") },
                reply: { assertionFailure("TODO: reply") },
                shareURL: URL(string: reply.comment.apId)
            )
        }
    }
}
