//
//  Inbox Reply View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-25.
//

import SwiftUI

// /user/replies

struct InboxReplyView: View {
    @ObservedObject var reply: ReplyModel
    @EnvironmentObject var inboxTracker: InboxTracker
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var unreadTracker: UnreadTracker
    
    var voteIconName: String { reply.votes.myVote == .downvote ? Icons.downvote : Icons.upvote }
    var iconName: String { reply.commentReply.read ? "arrowshape.turn.up.right" : "arrowshape.turn.up.right.fill" }
    
    var body: some View {
        NavigationLink(.lazyLoadPostLinkWithContext(.init(
            post: reply.post,
            scrollTarget: reply.comment.id
        ))) {
            content
                .padding(AppConstants.postAndCommentSpacing)
                .background(Color(uiColor: .systemBackground))
                .contentShape(Rectangle())
                .addSwipeyActions(reply.swipeActions(unreadTracker: unreadTracker, editorTracker: editorTracker))
                .contextMenu {
                    ForEach(reply.menuFunctions(
                        unreadTracker: unreadTracker,
                        editorTracker: editorTracker
                    )) { item in
                        MenuButton(menuFunction: item, confirmDestructive: nil)
                    }
                }
        }
        .buttonStyle(EmptyButtonStyle())
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: AppConstants.postAndCommentSpacing) {
            Text(reply.post.name)
                .font(.headline)
                .padding(.bottom, AppConstants.postAndCommentSpacing)
            
            UserLinkView(person: reply.creator, serverInstanceLocation: ServerInstanceLocation.bottom, overrideShowAvatar: true)
                .font(.subheadline)
            
            HStack(alignment: .top, spacing: AppConstants.postAndCommentSpacing) {
                Image(systemName: iconName)
                    .foregroundColor(.accentColor)
                    .frame(width: AppConstants.largeAvatarSize)
                
                MarkdownView(text: reply.comment.content, isNsfw: false)
                    .font(.subheadline)
            }
            
            CommunityLinkView(community: reply.community)
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: voteIconName)
                    Text(reply.votes.total.description)
                }
                .foregroundColor(reply.votes.myVote.color ?? .secondary)
                .onTapGesture {
                    Task(priority: .userInitiated) {
                        await reply.vote(inputOp: .upvote, unreadTracker: unreadTracker)
                    }
                }
                
                EllipsisMenu(
                    size: AppConstants.largeAvatarSize,
                    menuFunctions: reply.menuFunctions(unreadTracker: unreadTracker, editorTracker: editorTracker)
                )
                
                Spacer()
                
                PublishedTimestampView(date: reply.commentReply.published)
            }
        }
    }
}
