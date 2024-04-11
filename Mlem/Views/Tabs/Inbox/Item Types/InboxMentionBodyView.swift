//
//  InboxMentionBodyView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-25.
//

import SwiftUI

struct InboxMentionBodyView: View {
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var unreadTracker: UnreadTracker
    
    @ObservedObject var mention: MentionModel
    
    var voteIconName: String { mention.votes.myVote == .downvote ? Icons.downvote : Icons.upvote }
    var iconName: String { mention.personMention.read ? "quote.bubble" : "quote.bubble.fill" }
    
    var body: some View {
        NavigationLink(.lazyLoadPostLinkWithContext(.init(
            postId: mention.post.id,
            scrollTarget: mention.comment.id
        ))) {
            content
        }
        .buttonStyle(EmptyButtonStyle())
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            HStack(spacing: AppConstants.standardSpacing) {
                UserLinkView(
                    user: mention.creator,
                    serverInstanceLocation: .bottom,
                    bannedFromCommunity: mention.commentCreatorBannedFromCommunity,
                    overrideShowAvatar: true
                )
                    
                Spacer()
                    
                Image(systemName: iconName)
                    .foregroundColor(.accentColor)
                    .frame(width: AppConstants.largeAvatarSize)
                    
                EllipsisMenu(
                    size: AppConstants.largeAvatarSize,
                    menuFunctions: mention.menuFunctions(unreadTracker: unreadTracker, editorTracker: editorTracker)
                )
            }
                
            MarkdownView(text: mention.comment.content, isNsfw: false)
                .font(.subheadline)
                
            EmbeddedPost(community: mention.community.community, post: mention.post, comment: mention.comment)
        }
        .padding(.top, AppConstants.standardSpacing)
        .padding(.horizontal, AppConstants.standardSpacing)
    }
}
