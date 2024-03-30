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
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    
    var voteIconName: String { mention.votes.myVote == .downvote ? Icons.downvote : Icons.upvote }
    var iconName: String { mention.personMention.read ? "quote.bubble" : "quote.bubble.fill" }
    
    var body: some View {
        NavigationLink(.lazyLoadPostLinkWithContext(.init(
            postId: mention.post.id,
            scrollTarget: mention.comment.id
        ))) {
            content
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
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
                HStack(spacing: AppConstants.standardSpacing) {
                    UserLinkView(
                        user: mention.creator,
                        serverInstanceLocation: .bottom,
                        bannedFromCommunity: mention.creatorBannedFromCommunity,
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
  
            // TODO: NEXT reenable
//            InteractionBarView(
//                votes: mention.votes,
//                published: mention.published,
//                updated: mention.comment.updated,
//                commentCount: mention.numReplies,
//                saved: mention.saved,
//                accessibilityContext: "comment",
//                widgets: layoutWidgetTracker.groups.comment,
//                upvote: { assertionFailure("TODO: upvote") },
//                downvote: { assertionFailure("TODO: downvote") },
//                save: { assertionFailure("TODO: save") },
//                reply: { assertionFailure("TODO: reply") },
//                shareURL: URL(string: mention.comment.apId)
//            )
        }
    }
}
