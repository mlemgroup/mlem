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
    let comment: Comment
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                HStack {
                    ExpectedView(comment.creator) { creator in
                        FullyQualifiedLinkView(creator, labelStyle: .small)
                    } placeholder: {
                        Text(verbatim: .personPlaceholder).redacted(reason: .placeholder)
                    }
                    Spacer()
                    Image(icon: (notification.content.type == .mention) ? .lemmy.mention : .lemmy.reply)
                        .symbolVariant(notification.read ? .none : .fill)
                        .foregroundStyle(.themedAccent)
                    EllipsisMenu(size: 24) { comment.allMenuActions(
                        appState: appState,
                        navigation: navigation,
                        notification: notification
                    ) }
                    .frame(height: 10)
                }
                
                ExpectedView(comment.post) { post in
                    FooterLinkView(title: post.title, subtitle: nil)
                }
                
                MarkdownWithLinkList(comment.content)
            }
            .padding([.top, .horizontal], Constants.main.standardSpacing)
            
            InteractionBarView(
                appState: appState,
                navigation: navigation,
                comment: comment,
                notification: notification,
                configuration: replyInteractionBar
            )
        }
        .clipped()
        .background(.themedSecondaryGroupedBackground)
        .contentShape(.rect)
        .onTapGesture {
            navigation.push(.comment(comment))
        }
        .quickSwipes(notification: notification, configuration: replyInteractionBar)
        .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        .contextMenu { comment.allMenuActions(
            appState: appState,
            navigation: navigation,
            notification: notification
        ) }
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
    }
}
