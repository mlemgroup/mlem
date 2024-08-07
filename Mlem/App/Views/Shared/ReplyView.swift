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
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
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
                configuration: .init(
                    leading: [.counter(.score)],
                    trailing: [.action(.save)],
                    readouts: [.created, .score, .comment]
                )
            )
            .padding(.top, 2)
        }
        .padding(.vertical, 2)
        .padding(AppConstants.standardSpacing)
        .clipped()
        .background(palette.background)
        .contentShape(.rect)
        .onTapGesture {
            navigation.push(.expandedPost(reply.post, commentId: reply.commentId))
        }
        .quickSwipes(reply.swipeActions(behavior: .standard))
        .contextMenu { reply.menuActions() }
    }
}
