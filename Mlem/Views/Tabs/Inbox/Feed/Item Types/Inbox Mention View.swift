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
    
    init(account: SavedAccount, mention: APIPersonMentionView, menuFunctions: [MenuFunction]) {
        self.account = account
        self.mention = mention
        self.menuFunctions = menuFunctions
        
        self.publishedAgo = getTimeIntervalFromNow(date: mention.comment.published)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text(mention.post.name)
                .font(.headline)
                .padding(.bottom, spacing)
            
            UserProfileLink(user: mention.creator, showServerInstance: true)
                .font(.subheadline)
            
            HStack(alignment: .top, spacing: spacing) {
                Image(systemName: "quote.bubble.fill")
                    .foregroundColor(.accentColor)
                    .frame(width: userAvatarWidth)
                
                MarkdownView(text: mention.comment.content, isNsfw: false)
                    .font(.subheadline)
            }
            
            CommunityLinkView(community: mention.community)
            
            HStack {
                EllipsisMenu(size: userAvatarWidth, menuFunctions: menuFunctions)
//                Image(systemName: "ellipsis")
//                    .frame(width: userAvatarWidth)
                
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
