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
    
    let reply: ReplyModel
    let menuFunctions: [MenuFunction]
    
    let voteIconName: String
    let voteColor: Color
    
    var iconName: String { reply.commentReply.read ? "arrowshape.turn.up.right" : "arrowshape.turn.up.right.fill" }
    
    init(reply: ReplyModel, menuFunctions: [MenuFunction]) {
        self.reply = reply
        self.menuFunctions = menuFunctions
        
        switch reply.myVote {
        case .upvote:
            self.voteIconName = Icons.upvote
            self.voteColor = .upvoteColor
        case .downvote:
            self.voteIconName = Icons.downvote
            self.voteColor = .downvoteColor
        default:
            self.voteIconName = Icons.upvote
            self.voteColor = .secondary
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text(reply.post.name)
                .font(.headline)
                .padding(.bottom, spacing)
            
            UserLinkView(person: reply.creator, serverInstanceLocation: ServerInstanceLocation.bottom, overrideShowAvatar: true)
                .font(.subheadline)
            
            HStack(alignment: .top, spacing: spacing) {
                Image(systemName: iconName)
                    .foregroundColor(.accentColor)
                    .frame(width: userAvatarWidth)
                
                MarkdownView(text: reply.comment.content, isNsfw: false)
                    .font(.subheadline)
            }
            
            CommunityLinkView(community: reply.community)
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: voteIconName)
                    Text(reply.counts.score.description)
                }
                .foregroundColor(voteColor)
                
                EllipsisMenu(size: userAvatarWidth, menuFunctions: menuFunctions)
                
                Spacer()
                
                PublishedTimestampView(date: reply.commentReply.published)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}
