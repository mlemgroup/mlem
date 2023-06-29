//
//  Inbox Reply View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-25.
//

import SwiftUI

// /user/replies

struct InboxReplyView: View {
    let spacing: CGFloat = 10
    let userAvatarWidth: CGFloat = 30
    
    let account: SavedAccount
    let reply: APICommentReplyView
    let publishedAgo: String
    
    init(account: SavedAccount, reply: APICommentReplyView) {
        self.account = account
        self.reply = reply
        
        self.publishedAgo = getTimeIntervalFromNow(date: reply.commentReply.published)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text(reply.post.name)
                .font(.headline)
                .padding(.bottom, spacing)
            
            UserProfileLink(account: account, user: reply.creator, showServerInstance: true)
                .font(.subheadline)
            
            HStack(alignment: .top, spacing: spacing) {
                Image(systemName: "arrowshape.turn.up.right.fill")
                    .foregroundColor(.accentColor)
                    .frame(width: userAvatarWidth)
                
                MarkdownView(text: reply.comment.content, isNsfw: false)
                    .font(.subheadline)
            }
            
            CommunityLinkView(community: reply.community)
            
            HStack {
                Image(systemName: "ellipsis")
                    .frame(width: userAvatarWidth)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text(publishedAgo)
                }
                .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
