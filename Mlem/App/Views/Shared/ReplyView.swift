//
//  ReplyView.swift
//  Mlem
//
//  Created by Sjmarf on 04/07/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct ReplyView: View {
    @Setting(\.interactionBar_reply) var replyInteractionBar
    
    @Environment(AppState.self) private var appState
    @Environment(NavigationLayer.self) private var navigation
    
    let reply: Reply2
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            HStack {
                FullyQualifiedLinkView(reply.creator_, labelStyle: .small)
                Spacer()
                Image(systemName: reply.isMention ? Icons.mention : Icons.reply)
                    .symbolVariant(reply.read ? .none : .fill)
                    .foregroundStyle(.themedAccent)
                EllipsisMenu(size: 24) { reply.menuActions(appState: appState, navigation: navigation) }
                    .frame(height: 10)
            }
  
            FooterLinkView(title: reply.post.title, subtitle: nil)

            MarkdownWithLinkList(reply.comment.content)
            InteractionBarView(
                appState: appState,
                reply: reply,
                configuration: replyInteractionBar
            )
            .padding(.top, 1)
        }
        .padding(.vertical, 2)
        .padding(Constants.main.standardSpacing)
        .clipped()
        .background(.themedSecondaryGroupedBackground)
        .contentShape(.rect)
        .onTapGesture {
            navigation.push(.comment(reply.comment))
        }
        .quickSwipes(
            reply: reply,
            configuration: replyInteractionBar,
            behavior: .standard
        )
        .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        .contextMenu { reply.menuActions(appState: appState, navigation: navigation) }
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
    }
}
