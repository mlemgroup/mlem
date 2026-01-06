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
    
    let notification: InboxNotification
    let comment: Comment2
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                HStack {
                    FullyQualifiedLinkView(comment.creator_, labelStyle: .small)
                    Spacer()
                    Image(icon: (notification.content.type == .mention) ? .lemmy.mention : .lemmy.reply)
                        .symbolVariant(notification.read ? .none : .fill)
                        .foregroundStyle(.themedAccent)
                    // EllipsisMenu(size: 24) { comment.menuActions(appState: appState, navigation: navigation) }
                    //     .frame(height: 10)
                }
                
                FooterLinkView(title: comment.post.title, subtitle: nil)
                
                MarkdownWithLinkList(comment.content)
            }
            .padding([.top, .horizontal], Constants.main.standardSpacing)
            
            // InteractionBarView(
            //     appState: appState,
            //     reply: reply,
            //     configuration: replyInteractionBar
            // )
        }
        .clipped()
        .background(.themedSecondaryGroupedBackground)
        .contentShape(.rect)
        .onTapGesture {
            navigation.push(.comment(comment))
        }
        // .quickSwipes(reply: reply, configuration: replyInteractionBar)
        .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        // .contextMenu { reply.menuActions(appState: appState, navigation: navigation) }
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
    }
}
