//
//  SettingsPage.swift
//  Mlem
//
//  Created by Sjmarf on 07/05/2024.
//

import LemmyMarkdownUI
import SwiftUI

enum SettingsPage: Hashable {
    enum ContentActionType: Hashable {
        case post, comment, reply, postReport, commentReport
    }

    enum SwipeActionSettingType: Hashable {
        case post, comment, reply, postReport, commentReport, community
    }
    
    case root
    case accounts, account
    case profile, accountContent, accountAdvanced, accountSignIn, accountChangeEmail, accountLocal, accountChangePassword, accountLanguages
    case general, privacy, safety, accessibility, sorting, filters
    case zoomSlider
    case defaultFeed, haptics, accountAgeVisibility
    case privacyBypassImageProxy
    case safetyBlurNsfw, safetyWarnings
    case links, embedding
    case animatedAvatars
    case externalLinks, sharingLinks, tappableLinks
    case importExportSettings
    case theme, icon
    case post, comment, inbox, community, subscriptionList
    case tabBar, longPressAction
    case postThumbnail, postSubscriptionIndicator, postReadIndicator
    case commentMaximumDepth, commentJumpButton
    case inboxBadge
    case about, advanced, developer, errorLog
    case interactionBar(ContentActionType)
    case swipeActions(SwipeActionSettingType)
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
        case .accountAgeVisibility:
            AccountAgeVisibilitySettingsView()
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
        case .community:
            CommunitySettingsView()
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
        case .sharingLinks:
            SharingLinksSettingsView()
        case .tappableLinks:
            TappableLinksSettingsView()
        case .embedding:
            EmbeddingSettingsView()
        case .animatedAvatars:
            AnimatedAvatarSettingsView()
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
        case .longPressAction:
            LongPressActionSettingsView()
        case .inboxBadge:
            InboxBadgeSettingsView()
        case let .swipeActions(type):
            switch type {
            case .post:
                NewSwipeActionEditorView(\.interactionBar_post)
            case .comment:
                NewSwipeActionEditorView(\.interactionBar_comment)
            case .reply:
                NewSwipeActionEditorView(\.interactionBar_reply)
            case .postReport:
                SwipeActionEditorView(setting: \.interactionBar_postReport, isReport: true)
            case .commentReport:
                SwipeActionEditorView(setting: \.interactionBar_commentReport, isReport: true)
            case .community:
                NewSwipeActionEditorView(\.interactionBar_community)
            }
        case let .interactionBar(type):
            switch type {
            case .post:
                InteractionBarEditorView(setting: \.interactionBar_post, isReport: false)
            case .comment:
                InteractionBarEditorView(setting: \.interactionBar_comment, isReport: false)
            case .reply:
                InteractionBarEditorView(setting: \.interactionBar_reply, isReport: false)
            case .postReport:
                InteractionBarEditorView(setting: \.interactionBar_postReport, isReport: true)
            case .commentReport:
                InteractionBarEditorView(setting: \.interactionBar_commentReport, isReport: true)
            }
        case let .postBarWidgetPicker(configuration):
            InteractionBarWidgetPickerView<PostBarConfiguration>(configuration: configuration.wrappedValue)
        case let .commentBarWidgetPicker(configuration):
            InteractionBarWidgetPickerView<CommentBarConfiguration>(configuration: configuration.wrappedValue)
        case let .replyBarWidgetPicker(configuration):
            InteractionBarWidgetPickerView<ReplyBarConfiguration>(configuration: configuration.wrappedValue)
        case let .postReportBarWidgetPicker(configuration):
            InteractionBarWidgetPickerView<PostBarConfiguration>(configuration: configuration.wrappedValue)
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
    @Environment(\.palette) var palette
    
    let doc: Document
    
    var body: some View {
        ScrollView {
            Markdown(doc.body, configuration: .default(palette: palette))
                .padding(Constants.main.standardSpacing)
        }
        .background(.themedBackground)
    }
}
