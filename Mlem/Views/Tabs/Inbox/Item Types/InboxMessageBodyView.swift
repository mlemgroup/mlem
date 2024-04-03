//
//  InboxMessageBodyView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-25.
//

import Dependencies
import SwiftUI

struct InboxMessageBodyView: View {
    @Dependency(\.siteInformation) var siteInformation
    
    @ObservedObject var message: MessageModel
    @EnvironmentObject var inboxTracker: InboxTracker
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var unreadTracker: UnreadTracker
    
    var isOwnMessage: Bool { siteInformation.userId == message.creatorId }
    
    var iconName: String {
        isOwnMessage ? Icons.send :
            message.privateMessage.read ? "envelope.open" : "envelope.fill"
    }
    
    var verb: String { isOwnMessage ? "Sent" : "Received" }
    
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
            HStack(spacing: AppConstants.standardSpacing) {
                if isOwnMessage {
                    UserLinkView(
                        user: message.recipient,
                        serverInstanceLocation: .bottom,
                        bannedFromCommunity: false,
                        overrideShowAvatar: true
                    )
                } else {
                    UserLinkView(
                        user: message.creator,
                        serverInstanceLocation: .bottom,
                        bannedFromCommunity: false,
                        overrideShowAvatar: true
                    )
                }
                
                Spacer()
                
                Image(systemName: iconName)
                    .foregroundColor(.accentColor)
                    .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
                
                EllipsisMenu(
                    size: AppConstants.largeAvatarSize,
                    menuFunctions: message.menuFunctions(
                        unreadTracker: unreadTracker,
                        editorTracker: editorTracker
                    )
                )
            }
            
            MarkdownView(text: message.privateMessage.content, isNsfw: false)
                .font(.subheadline)
            
            Text("\(verb) \(message.published.getRelativeTime())")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
