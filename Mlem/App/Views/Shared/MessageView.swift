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
    @Environment(\.reportContext) private var reportContext
    
    @Setting(\.menus_modActionGrouping) var moderatorActionGrouping
    
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
                FullyQualifiedLinkView(message.creator_, labelStyle: .small)
                Spacer()
                if isInInbox {
                    Image(icon: message.isOwnMessage ? .lemmy.send : .lemmy.message)
                        .symbolVariant(message.shimRead ? .none : .fill)
                        .foregroundStyle(.themedAccent)
                }
                ellipsisMenus
                    .frame(height: 10)
            }
            if message.deleted {
                Text("Message was deleted")
                    .italic()
                    .foregroundStyle(.themedSecondary)
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
            .foregroundStyle(.themedSecondary)
            embeddedContent
        }
        .padding(.vertical, 2)
        .padding(Constants.main.standardSpacing)
        .clipped()
        .background(.themedSecondaryGroupedBackground)
        .contentShape(.rect)
        .quickSwipes(message.swipeActions(appState: appState))
        .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        .contextMenu {
            message.allMenuActions(appState: appState, editCallback: editMessage, navigation: navigation, report: reportContext)
        }
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        .onTapGesture {
            if let otherPerson, message.api.canInteract(appState: appState) {
                navigation.push(.messageFeed(otherPerson))
            }
        }
    }
    
    var ellipsisMenus: some View {
        HStack {
            if moderatorActionGrouping == .separateMenu {
                if message.api.isAdmin {
                    EllipsisMenu(icon: .lemmy.moderation, size: 24) {
                        message.moderatorMenuActions(appState: appState, report: reportContext)
                    }
                }
                EllipsisMenu(size: 24) {
                    message.basicMenuActions(appState: appState, editCallback: editMessage, navigation: navigation)
                }
            } else {
                EllipsisMenu(size: 24) {
                    message.allMenuActions(appState: appState, editCallback: editMessage, navigation: navigation, report: reportContext)
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
