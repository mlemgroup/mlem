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
    case profile, accountGeneral, accountAdvanced, accountSignIn, accountChangeEmail, accountLocal, accountChangePassword
    case general, privacy, safety, accessibility, sorting, filters
    case privacyBypassImageProxy
    case safetyBlurNsfw, safetyWarnings
    case links, embedding
    case externalLinks, tappableLinks
    case importExportSettings
    case theme, icon
    case post, comment, inbox, subscriptionList, tabBar
    case postThumbnail, postSubscriptionIndicator, postReadIndicator
    case commentMaximumDepth, commentJumpButton
    case inboxBadge
    case about, advanced, developer, errorLog
    case postInteractionBar, commentInteractionBar, replyInteractionBar
    case moderation
    case licences, document(Document)
    
    @ViewBuilder
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func view() -> some View {
        switch self {
        case .root:
            SettingsView()
        case .account:
            AccountSettingsView()
        case .profile:
            if let person = AppState.main.firstPerson {
                ProfileSettingsView(person: person)
            } else {
                Text(verbatim: "Error: No active user account")
            }
        case .accountGeneral:
            AccountGeneralSettingsView()
        case .accountSignIn:
            AccountSignInSettingsView()
        case .accountAdvanced:
            AccountAdvancedSettingsView()
        case .accountChangeEmail:
            AccountEmailSettingsView()
        case .accountChangePassword:
            ChangePasswordView()
        case .accountLocal:
            AccountLocalSettingsView()
        case .accounts:
            AccountListSettingsView()
        case .general:
            GeneralSettingsView()
        case .privacy:
            PrivacySettingsView()
        case .privacyBypassImageProxy:
            PrivacyBypassImageProxySettingsView()
        case .safety:
            SafetySettingsView()
        case .safetyBlurNsfw:
            SafetyBlurNsfwSettingsView()
        case .safetyWarnings:
            SafetyWarningsSettingsView()
        case .accessibility:
            AccessibilitySettingsView()
        case .importExportSettings:
            ImportExportSettingsView()
        case .advanced:
            AdvancedSettingsView()
        case .developer:
            DeveloperSettingsView()
        case .errorLog:
            ErrorLogView()
        case .about:
            AboutMlemView()
        case .theme:
            ThemeSettingsView()
        case .icon:
            IconSettingsView()
        case .post:
            PostSettingsView()
        case .postThumbnail:
            PostThumbnailSettingsView()
        case .postSubscriptionIndicator:
            PostSubscriptionIndicatorSettingsView()
        case .postReadIndicator:
            PostReadIndicatorSettingsView()
        case .comment:
            CommentSettingsView()
        case .commentMaximumDepth:
            CommentMaximumDepthSettingsView()
        case .commentJumpButton:
            CommentJumpButtonSettingsView()
        case .inbox:
            InboxSettingsView()
        case .links:
            LinkSettingsView()
        case .externalLinks:
            ExternalLinkSettingsView()
        case .tappableLinks:
            TappableLinksSettingsView()
        case .embedding:
            EmbeddingSettingsView()
        case .sorting:
            SortingSettingsView()
        case .filters:
            FiltersSettingsView()
        case .moderation:
            ModeratorSettingsView()
        case .subscriptionList:
            SubscriptionListSettingsView()
        case .tabBar:
            TabBarSettingsView()
        case .inboxBadge:
            InboxBadgeSettingsView()
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
