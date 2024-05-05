//
//  InboxReplyBodyView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-25.
//

import SwiftUI

struct InboxReplyBodyView: View {
    @ObservedObject var reply: ReplyModel
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var unreadTracker: UnreadTracker
    
    var voteIconName: String { reply.votes.myVote == .downvote ? Icons.downvote : Icons.upvote }
    var iconName: String { reply.commentReply.read ? "arrowshape.turn.up.right" : "arrowshape.turn.up.right.fill" }
    
    var body: some View {
        NavigationLink(.lazyLoadPostLinkWithContext(.init(
            postId: reply.post.id,
            scrollTarget: reply.comment.id
        ))) {
            content
        }
        .buttonStyle(EmptyButtonStyle())
    }
    
    var content: some View {
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
    }
}
