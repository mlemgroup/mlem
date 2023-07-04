//
//  Inbox Message View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-25.
//

import SwiftUI

struct InboxMessageView: View {
    let spacing: CGFloat = 10
    let userAvatarWidth: CGFloat = 30
    
    let account: SavedAccount
    let message: APIPrivateMessageView
    let menuFunctions: [MenuFunction]
    let publishedAgo: String
    
    init(account: SavedAccount, message: APIPrivateMessageView, menuFunctions: [MenuFunction]) {
        self.account = account
        self.message = message
        self.menuFunctions = menuFunctions
        
        self.publishedAgo = getTimeIntervalFromNow(date: message.privateMessage.published)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text("Direct message")
                .font(.headline.smallCaps())
                .padding(.bottom, spacing)
            
            HStack(alignment: .top, spacing: spacing) {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.accentColor)
                    .frame(width: userAvatarWidth)
                
                MarkdownView(text: message.privateMessage.content, isNsfw: false)
                    .font(.subheadline)
            }
            
            UserProfileLink(account: account, user: message.creator, serverInstanceLocation: .bottom)
                .font(.subheadline)
            
            HStack {
//                Image(systemName: "ellipsis")
//                    .frame(width: userAvatarWidth)
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
