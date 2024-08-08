//
//  MessageView.swift
//  Mlem
//
//  Created by Sjmarf on 05/07/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct MessageView: View {
    @Environment(Palette.self) private var palette
    @Environment(AppState.self) private var appState
    
    let message: any Message
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            HStack {
                FullyQualifiedLinkView(entity: message.creator_, labelStyle: .small, showAvatar: true)
                Spacer()
                Image(systemName: message.isOwnMessage ? Icons.send : Icons.message)
                    .symbolVariant(message.read ? .none : .fill)
                    .foregroundStyle(palette.accent)
                EllipsisMenu(size: 24) { message.menuActions() }
                    .frame(height: 10)
            }
            if message.deleted {
                Text("Message was deleted")
                    .italic()
                    .foregroundStyle(palette.secondary)
            } else {
                Markdown(message.content, configuration: .default)
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
        }
        .padding(.vertical, 2)
        .padding(Constants.main.standardSpacing)
        .clipped()
        .background(palette.background)
        .contentShape(.rect)
        .quickSwipes(message.swipeActions(behavior: .standard))
        .contextMenu { message.menuActions() }
    }
}
