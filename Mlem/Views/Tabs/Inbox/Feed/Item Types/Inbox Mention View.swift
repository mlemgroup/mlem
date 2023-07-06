//
//  Inbox Mention View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-25.
//

import SwiftUI

struct InboxMentionView: View {
    let spacing: CGFloat = 10
    let userAvatarWidth: CGFloat = 30
    
    let account: SavedAccount
    let mention: APIPersonMentionView
    let menuFunctions: [MenuFunction]
    
    let publishedAgo: String
    
    let voteIconName: String
    let voteColor: Color
    
    var iconName: String { mention.personMention.read ? "quote.bubble" : "quote.bubble.fill" }
    
    init(account: SavedAccount, mention: APIPersonMentionView, menuFunctions: [MenuFunction]) {
        self.account = account
        self.mention = mention
        self.menuFunctions = menuFunctions
        
        switch mention.myVote {
        case .upvote:
            voteIconName = "arrow.up"
            voteColor = .upvoteColor
        case .downvote:
            voteIconName = "arrow.down"
            voteColor = .downvoteColor
        default:
            voteIconName = "arrow.up"
            voteColor = .secondary
        }
        
        self.publishedAgo = getTimeIntervalFromNow(date: mention.comment.published)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text(mention.post.name)
                .font(.headline)
                .padding(.bottom, spacing)
            
            UserProfileLink(user: mention.creator,
                            serverInstanceLocation: .bottom,
                            overrideShowAvatar: true)
                .font(.subheadline)
            
            HStack(alignment: .top, spacing: spacing) {
                Image(systemName: iconName)
                    .foregroundColor(.accentColor)
                    .frame(width: userAvatarWidth)
                
                MarkdownView(text: mention.comment.content, isNsfw: false)
                    .font(.subheadline)
            }
            
            CommunityLinkView(community: mention.community)
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: voteIconName)
                    Text(mention.counts.score.description)
                }
                .foregroundColor(voteColor)
                
                EllipsisMenu(size: userAvatarWidth, menuFunctions: menuFunctions)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text(publishedAgo)
                }
                .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}
