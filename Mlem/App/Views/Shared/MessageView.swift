//
//  MessageView.swift
//  Mlem
//
//  Created by Sjmarf on 05/07/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct MessageView<EmbeddedContent: View>: View {
    @Environment(AppState.self) private var appState
    @Environment(NavigationLayer.self) private var navigation
    @Environment(Palette.self) private var palette
    @Environment(\.reportContext) private var reportContext
    
    @Setting(\.moderatorActionGrouping) var moderatorActionGrouping
    
    let message: any Message
    let isInInbox: Bool
    let embeddedContent: EmbeddedContent
    
    init(
        message: any Message,
        isInInbox: Bool = false,
        @ViewBuilder embeddedContent: () -> EmbeddedContent = { EmptyView() }
    ) {
        self.message = message
        self.isInInbox = isInInbox
        self.embeddedContent = embeddedContent()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            HStack {
                FullyQualifiedLinkView(entity: message.creator_, labelStyle: .small, showAvatar: true)
                Spacer()
                if isInInbox {
                    Image(systemName: message.isOwnMessage ? Icons.send : Icons.message)
                        .symbolVariant(message.read ? .none : .fill)
                        .foregroundStyle(palette.accent)
                }
                ellipsisMenus
                    .frame(height: 10)
            }
            if message.deleted {
                Text("Message was deleted")
                    .italic()
                    .foregroundStyle(palette.secondary)
            } else {
                MarkdownWithLinkList(message.content)
            }
            Group {
                if message.isOwnMessage {
                    Text("Sent \(message.created.getRelativeTime())")
                } else {
                    Text("Received \(message.created.getRelativeTime())")
                }
            }
            .font(.caption)
            .foregroundStyle(palette.secondary)
            embeddedContent
        }
        .padding(.vertical, 2)
        .padding(Constants.main.standardSpacing)
        .clipped()
        .background(palette.secondaryGroupedBackground)
        .contentShape(.rect)
        .quickSwipes(message.swipeActions(behavior: .standard))
        .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        .contextMenu {
            message.allMenuActions(editCallback: editMessage, navigation: navigation, report: reportContext)
        }
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        .onTapGesture {
            if let otherPerson, message.api.canInteract {
                navigation.push(.messageFeed(otherPerson))
            }
        }
    }
    
    var ellipsisMenus: some View {
        HStack {
            if moderatorActionGrouping == .separateMenu {
                if message.api.isAdmin {
                    EllipsisMenu(systemImage: Icons.moderation, size: 24) {
                        message.moderatorMenuActions(report: reportContext)
                    }
                }
                EllipsisMenu(size: 24) {
                    message.basicMenuActions(editCallback: editMessage, navigation: navigation)
                }
            } else {
                EllipsisMenu(size: 24) {
                    message.allMenuActions(editCallback: editMessage, navigation: navigation, report: reportContext)
                }
            }
        }
    }
    
    var otherPerson: Person1? {
        message.isOwnMessage ? message.recipient_ : message.creator_
    }
    
    @MainActor
    func editMessage() {
        if let otherPerson {
            navigation.push(.messageFeed(otherPerson, focusTextField: true, editing: message))
        }
    }
}
