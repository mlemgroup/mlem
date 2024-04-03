//
//  InboxMentionBodyView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-25.
//

import SwiftUI

struct InboxMentionBodyView: View {
    @EnvironmentObject var inboxTracker: InboxTracker
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var unreadTracker: UnreadTracker
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    
    @ObservedObject var mention: MentionModel
    
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
