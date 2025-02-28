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
    case profile, accountContent, accountAdvanced, accountSignIn, accountChangeEmail, accountLocal, accountChangePassword, accountLanguages
    case general, privacy, safety, accessibility, sorting, filters
    case zoomSlider
    case defaultFeed, haptics
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
    case postInteractionBar, commentInteractionBar, replyInteractionBar, postReportInteractionBar, commentReportInteractionBar
    case postBarWidgetPicker(HashWrapper<Binding<PostBarConfiguration>>)
    case commentBarWidgetPicker(HashWrapper<Binding<CommentBarConfiguration>>)
    case replyBarWidgetPicker(HashWrapper<Binding<ReplyBarConfiguration>>)
    case postReportBarWidgetPicker(HashWrapper<Binding<PostBarConfiguration>>)
    case commentReportBarWidgetPicker(HashWrapper<Binding<CommentBarConfiguration>>)
    case moderation
    case modMailInteractionBar
    case separateModeratorActions
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
        case .accountContent:
            AccountContentSettingsView()
        case .accountSignIn:
            AccountSignInSettingsView()
        case .accountAdvanced:
            AccountAdvancedSettingsView()
        case .accountChangeEmail:
            AccountEmailSettingsView()
        case .accountChangePassword:
            ChangePasswordView()
        case .accountLanguages:
            DiscussionLanguageSettingsView()
        case .accountLocal:
            AccountLocalSettingsView()
        case .accounts:
            AccountListSettingsView()
        case .general:
            GeneralSettingsView()
        case .defaultFeed:
            DefaultFeedSettingsView()
        case .haptics:
            HapticSettingsView()
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
        case .zoomSlider:
            ZoomSliderSettingsView()
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
        case .modMailInteractionBar:
            ModMailInteractionBarSettingsView()
        case .separateModeratorActions:
            ModeratorActionSeparationSettingsView()
        case .subscriptionList:
            SubscriptionListSettingsView()
        case .tabBar:
            TabBarSettingsView()
        case .inboxBadge:
            InboxBadgeSettingsView()
        case .postInteractionBar:
            InteractionBarEditorView(setting: \.postInteractionBar, isReport: false)
        case let .postBarWidgetPicker(configuration):
            InteractionBarWidgetPickerView<PostBarConfiguration>(configuration: configuration.wrappedValue)
        case .commentInteractionBar:
            InteractionBarEditorView(setting: \.commentInteractionBar, isReport: false)
        case let .commentBarWidgetPicker(configuration):
            InteractionBarWidgetPickerView<CommentBarConfiguration>(configuration: configuration.wrappedValue)
        case .replyInteractionBar:
            InteractionBarEditorView(setting: \.replyInteractionBar, isReport: false)
        case let .replyBarWidgetPicker(configuration):
            InteractionBarWidgetPickerView<ReplyBarConfiguration>(configuration: configuration.wrappedValue)
        case .postReportInteractionBar:
            InteractionBarEditorView(setting: \.postReportInteractionBar, isReport: true)
        case let .postReportBarWidgetPicker(configuration):
            InteractionBarWidgetPickerView<PostBarConfiguration>(configuration: configuration.wrappedValue)
        case .commentReportInteractionBar:
            InteractionBarEditorView(setting: \.commentReportInteractionBar, isReport: true)
        case let .commentReportBarWidgetPicker(configuration):
            InteractionBarWidgetPickerView<CommentBarConfiguration>(configuration: configuration.wrappedValue)
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
    
    static func postBarWidgetPicker(_ configuration: Binding<PostBarConfiguration>) -> SettingsPage {
        .postBarWidgetPicker(.init(wrappedValue: configuration))
    }
    
    static func commentBarWidgetPicker(_ configuration: Binding<CommentBarConfiguration>) -> SettingsPage {
        .commentBarWidgetPicker(.init(wrappedValue: configuration))
    }
    
    static func replyBarWidgetPicker(_ configuration: Binding<ReplyBarConfiguration>) -> SettingsPage {
        .replyBarWidgetPicker(.init(wrappedValue: configuration))
    }
    
    static func postReportBarWidgetPicker(_ configuration: Binding<PostBarConfiguration>) -> SettingsPage {
        .postReportBarWidgetPicker(.init(wrappedValue: configuration))
    }
    
    static func commentReportBarWidgetPicker(_ configuration: Binding<CommentBarConfiguration>) -> SettingsPage {
        .commentReportBarWidgetPicker(.init(wrappedValue: configuration))
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
