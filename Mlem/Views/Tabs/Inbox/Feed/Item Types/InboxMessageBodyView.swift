//
//  InboxMessageBodyView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-25.
//

import SwiftUI

struct InboxMessageBodyView: View {
    @ObservedObject var message: MessageModel
    @EnvironmentObject var inboxTracker: InboxTracker
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var unreadTracker: UnreadTracker
    
    var iconName: String { message.privateMessage.read ? "envelope.open" : "envelope.fill" }
    
    init(message: MessageModel) {
        self.message = message
    }
    
    var body: some View {
        content
            .padding(AppConstants.standardSpacing)
            .background(Color(uiColor: .systemBackground))
            .contentShape(Rectangle())
            .contextMenu {
                ForEach(message.menuFunctions(
                    unreadTracker: unreadTracker,
                    editorTracker: editorTracker
                )) { item in
                    MenuButton(menuFunction: item, menuFunctionPopup: .constant(nil))
                }
            }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            Text("Direct Message")
                .font(.headline.smallCaps())
                .padding(.bottom, AppConstants.standardSpacing)
            
            HStack(alignment: .top, spacing: AppConstants.standardSpacing) {
                Image(systemName: iconName)
                    .foregroundColor(.accentColor)
                    .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
                
                MarkdownView(text: message.privateMessage.content, isNsfw: false)
                    .font(.subheadline)
            }
            
            UserLinkView(
                user: message.creator,
                serverInstanceLocation: .bottom,
                bannedFromCommunity: false,
                overrideShowAvatar: true
            )
            .font(.subheadline)
            
            HStack {
                EllipsisMenu(
                    size: AppConstants.largeAvatarSize,
                    menuFunctions: message.menuFunctions(
                        unreadTracker: unreadTracker,
                        editorTracker: editorTracker
                    )
                )
                
                Spacer()
                
                PublishedTimestampView(date: message.privateMessage.published)
            }
        }
    }
}
