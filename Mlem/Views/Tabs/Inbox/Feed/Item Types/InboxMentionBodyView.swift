//
//  InboxMentionBodyView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-25.
//

import SwiftUI

struct InboxMentionBodyView: View {
    @ObservedObject var mention: MentionModel
    @EnvironmentObject var inboxTracker: InboxTracker
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var unreadTracker: UnreadTracker
    
    var voteIconName: String { mention.votes.myVote == .downvote ? Icons.downvote : Icons.upvote }
    var iconName: String { mention.personMention.read ? "quote.bubble" : "quote.bubble.fill" }
    
    var body: some View {
        NavigationLink(.lazyLoadPostLinkWithContext(.init(
            postId: mention.post.id,
            scrollTarget: mention.comment.id
        ))) {
            content
                .padding(AppConstants.standardSpacing)
                .background(Color(uiColor: .systemBackground))
                .contentShape(Rectangle())
                .contextMenu {
                    ForEach(mention.menuFunctions(
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
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            Text(mention.post.name)
                .font(.headline)
                .padding(.bottom, AppConstants.standardSpacing)
            
            UserLinkView(
                user: mention.creator,
                serverInstanceLocation: .bottom,
                bannedFromCommunity: mention.creatorBannedFromCommunity,
                overrideShowAvatar: true
            )
            .font(.subheadline)
            
            HStack(alignment: .top, spacing: AppConstants.standardSpacing) {
                Image(systemName: iconName)
                    .foregroundColor(.accentColor)
                    .frame(width: AppConstants.largeAvatarSize)
                
                MarkdownView(text: mention.comment.content, isNsfw: false)
                    .font(.subheadline)
            }
            
            CommunityLinkView(community: mention.community)
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: voteIconName)
                    Text(mention.votes.total.description)
                }
                .foregroundColor(mention.votes.myVote.color ?? .secondary)
                .onTapGesture {
                    Task(priority: .userInitiated) {
                        await mention.vote(inputOp: .upvote, unreadTracker: unreadTracker)
                    }
                }
                
                EllipsisMenu(
                    size: AppConstants.largeAvatarSize,
                    menuFunctions: mention.menuFunctions(unreadTracker: unreadTracker, editorTracker: editorTracker)
                )
                
                Spacer()
                
                PublishedTimestampView(date: mention.comment.published)
            }
        }
    }
}
