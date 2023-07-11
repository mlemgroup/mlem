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
    
    let message: APIPrivateMessageView
    let menuFunctions: [MenuFunction]
    
    var iconName: String { message.privateMessage.read ? "envelope.open" : "envelope.fill" }
    
    init(message: APIPrivateMessageView, menuFunctions: [MenuFunction]) {
        self.message = message
        self.menuFunctions = menuFunctions
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text("Direct message")
                .font(.headline.smallCaps())
                .padding(.bottom, spacing)
            
            HStack(alignment: .top, spacing: spacing) {
                Image(systemName: iconName)
                    .foregroundColor(.accentColor)
                    .frame(height: userAvatarWidth)
                
                MarkdownView(text: message.privateMessage.content, isNsfw: false)
                    .font(.subheadline)
            }
            
            UserProfileLink(user: message.creator,
                            serverInstanceLocation: .bottom,
                            overrideShowAvatar: true)
                .font(.subheadline)
            
            HStack {
                EllipsisMenu(size: userAvatarWidth, menuFunctions: menuFunctions)
                
                Spacer()
                
                TimestampView(date: message.privateMessage.published)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}
