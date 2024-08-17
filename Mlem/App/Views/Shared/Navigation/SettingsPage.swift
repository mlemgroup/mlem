//
//  SettingsPage.swift
//  Mlem
//
//  Created by Sjmarf on 07/05/2024.
//

import SwiftUI

enum SettingsPage: Hashable {
    case root, accounts, account, theme, post, links, subscriptionList, icon, sorting
    case postInteractionBar, commentInteractionBar, replyInteractionBar
    
    @ViewBuilder
    // swiftlint:disable:next cyclomatic_complexity
    func view() -> some View {
        switch self {
        case .root:
            SettingsView()
        case .account:
            AccountSettingsView()
        case .accounts:
            AccountListSettingsView()
        case .theme:
            ThemeSettingsView()
        case .icon:
            IconSettingsView()
        case .post:
            PostSettingsView()
        case .links:
            LinkSettingsView()
        case .sorting:
            SortingSettingsView()
        case .subscriptionList:
            SubscriptionListSettingsView()
        case .postInteractionBar:
            InteractionBarEditorView(configuration: PostBarConfiguration.default)
        case .commentInteractionBar:
            InteractionBarEditorView(configuration: CommentBarConfiguration.default)
        case .replyInteractionBar:
            InteractionBarEditorView(configuration: ReplyBarConfiguration.default)
        }
    }
}
