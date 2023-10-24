//
//  Inbox Message View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-25.
//

import SwiftUI

struct InboxMessageView: View {
    @ObservedObject var message: MessageModel
    
    var iconName: String { message.privateMessage.read ? "envelope.open" : "envelope.fill" }
    
    init(message: MessageModel) {
        self.message = message
    }
    
    var body: some View {
        content
            .padding(AppConstants.postAndCommentSpacing)
            .background(Color(uiColor: .systemBackground))
            .contentShape(Rectangle())
            .contextMenu {
                ForEach(message.menuFunctions()) { item in
                    MenuButton(menuFunction: item, confirmDestructive: nil)
                }
            }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: AppConstants.postAndCommentSpacing) {
            Text("Direct message")
                .font(.headline.smallCaps())
                .padding(.bottom, AppConstants.postAndCommentSpacing)
            
            HStack(alignment: .top, spacing: AppConstants.postAndCommentSpacing) {
                Image(systemName: iconName)
                    .foregroundColor(.accentColor)
                    .frame(width: AppConstants.largeAvatarSize)
                
                MarkdownView(text: message.privateMessage.content, isNsfw: false)
                    .font(.subheadline)
            }
            
            UserLinkView(
                person: message.creator,
                serverInstanceLocation: .bottom,
                overrideShowAvatar: true
            )
            .font(.subheadline)
            
            HStack {
                EllipsisMenu(size: AppConstants.largeAvatarSize, menuFunctions: message.menuFunctions())
                
                Spacer()
                
                PublishedTimestampView(date: message.privateMessage.published)
            }
        }
    }
}
