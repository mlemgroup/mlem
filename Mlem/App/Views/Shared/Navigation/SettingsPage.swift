//
//  SettingsPage.swift
//  Mlem
//
//  Created by Sjmarf on 07/05/2024.
//

import LemmyMarkdownUI
import SwiftUI

enum SettingsPage: Hashable {
    case root
    case accounts, account
    case general, links, sorting
    case theme, icon
    case post, comment, inbox, subscriptionList
    case about, advanced
    case postInteractionBar, commentInteractionBar, replyInteractionBar
    case licences, document(Document)
    
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
        case .general:
            GeneralSettingsView()
        case .advanced:
            AdvancedSettingsView()
        case .about:
            AboutMlemView()
        case .theme:
            ThemeSettingsView()
        case .icon:
            IconSettingsView()
        case .post:
            PostSettingsView()
        case .comment:
            CommentSettingsView()
        case .inbox:
            InboxSettingsView()
        case .links:
            LinkSettingsView()
        case .sorting:
            SortingSettingsView()
        case .subscriptionList:
            SubscriptionListSettingsView()
        case .postInteractionBar:
            InteractionBarEditorView(setting: \.postInteractionBar)
        case .commentInteractionBar:
            InteractionBarEditorView(setting: \.commentInteractionBar)
        case .replyInteractionBar:
            InteractionBarEditorView(setting: \.replyInteractionBar)
        case let .document(doc):
            SimpleMarkdownPage(doc: doc)
        case .licences:
            Form {
                ForEach(Document.allLicenses) { doc in
                    NavigationLink(doc.title, destination: .settings(.document(doc)))
                }
            }
        }
    }
}

private struct SimpleMarkdownPage: View {
    @Environment(Palette.self) var palette
    
    let doc: Document
    
    var body: some View {
        ScrollView {
            Markdown(doc.body, configuration: .default)
                .padding(Constants.main.standardSpacing)
        }
        .background(palette.background)
    }
}
