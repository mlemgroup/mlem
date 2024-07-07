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
    
    var isOwnMessage: Bool { (appState.firstAccount as? UserAccount)?.id == message.creatorId }
    
    let message: any Message
    
    var verb: String { isOwnMessage ? "Sent" : "Received" }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            HStack {
                FullyQualifiedLinkView(entity: message.creator_, labelStyle: .small, showAvatar: true)
                Spacer()
                Image(systemName: Icons.message)
                    .symbolVariant(message.read ? .none : .fill)
                    .foregroundStyle(palette.accent)
            }
            Markdown(message.content, configuration: .default)
            Text("\(verb) \(message.created.getRelativeTime())")
                .font(.caption)
                .foregroundStyle(palette.secondary)
        }
        .padding(.vertical, 2)
        .padding(AppConstants.standardSpacing)
        .clipped()
        .background(palette.background)
        .contentShape(.rect)
        .quickSwipes(message.swipeActions(behavior: .standard))
        .contextMenu(actions: message.menuActions())
    }
}
