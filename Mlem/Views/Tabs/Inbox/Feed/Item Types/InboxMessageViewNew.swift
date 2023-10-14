//
//  InboxMessageViewNew.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-13.
//

import SwiftUI

struct InboxMessageViewNew: View {
    let spacing: CGFloat = 10
    let userAvatarWidth: CGFloat = 30
    
    let message: MessageModel
    let menuFunctions: [MenuFunction]
    
    var iconName: String { message.privateMessage.read ? "envelope.open" : "envelope.fill" }
    
    init(message: MessageModel, menuFunctions: [MenuFunction]) {
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
            
            UserLinkView(
                user: message.creator,
                serverInstanceLocation: .bottom,
                overrideShowAvatar: true
            )
            .font(.subheadline)
            
            HStack {
                EllipsisMenu(size: userAvatarWidth, menuFunctions: menuFunctions)
                
                Spacer()
                
                PublishedTimestampView(date: message.privateMessage.published)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}
