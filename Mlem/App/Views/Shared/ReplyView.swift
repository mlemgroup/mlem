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
    @Environment(Palette.self) private var palette
    @Environment(NavigationLayer.self) private var navigation
    
    let reply: Reply2
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            HStack {
                FullyQualifiedLinkView(entity: reply.creator_, labelStyle: .small, showAvatar: true)
                Spacer()
                Image(systemName: reply.isMention ? Icons.mention : Icons.reply)
                    .symbolVariant(reply.read ? .none : .fill)
                    .foregroundStyle(palette.accent)
                EllipsisMenu(size: 24) { reply.menuActions() }
                    .frame(height: 10)
            }
          
            Markdown(reply.comment.content, configuration: .default)
            InteractionBarView(
                reply: reply,
                configuration: InteractionBarTracker.main.replyInteractionBar
            )
            .padding(.top, 2)
        }
        .padding(.vertical, 2)
        .padding(Constants.main.standardSpacing)
        .clipped()
        .background(palette.secondaryGroupedBackground)
        .contentShape(.rect)
        .onTapGesture {
            navigation.push(.post(reply.post, highlightedComment: reply.comment))
        }
        .quickSwipes(reply.swipeActions(behavior: .standard))
        .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        .contextMenu { reply.menuActions() }
    }
}
