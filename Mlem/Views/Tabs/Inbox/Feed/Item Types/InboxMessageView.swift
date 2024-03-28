//
//  InboxMessageView.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-12-22.
//

import SwiftUI

struct InboxMessageView: View {
    @ObservedObject var message: MessageModel
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var unreadTracker: UnreadTracker
    
    var iconName: String { message.privateMessage.read ? "envelope.open" : "envelope.fill" }

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
            .addSwipeyActions(
                message.swipeActions(
                    unreadTracker: unreadTracker,
                    editorTracker: editorTracker
                )
            )
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            Text("Direct message")
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
