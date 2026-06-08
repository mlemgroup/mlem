//
//  SettingsPage.swift
//  Mlem
//
//  Created by Sjmarf on 07/05/2024.
//

import LemmyMarkdownUI
import SwiftUI

// swiftlint:disable:next type_body_length
enum SettingsPage: Hashable {
    enum ContentActionType: Hashable {
        case post, comment, inboxNotification, postReport, commentReport
    }

    enum SwipeActionSettingType: Hashable {
        case post, comment, inboxNotification, postReport, commentReport, community, person, instance
    }

    case root
    case accounts, account
    case profile, accountContent, accountAdvanced, accountSignIn, accountChangeEmail, accountLocal, accountChangePassword, accountLanguages
    case general, privacy, safety, accessibility, sorting, filters
    case zoomSlider
    case defaultFeed, haptics, accountAgeVisibility
    case privacyBypassImageProxy
    case safetyBlurNsfw, safetyWarnings
    case mediaAndLinks, embedding
    case imageViewer, imageViewerControls, imageViewerDismissSensitivity
    case avatars, animatedAvatars
    case externalLinks, sharingLinks, tapFriendlyLinks
    case importExportSettings
    case theme, icon
    case post, comment, inbox, community, person, instance, subscriptionList
    case tabBar, longPressAction
    case postThumbnail, postSubscriptionIndicator, postReadIndicator
    case commentMaximumDepth, commentJumpButton
    case inboxBadge
    case about, advanced, developer, errorLog, errorToastTimeout
    case interactionBar(ContentActionType)
    case swipeActions(SwipeActionSettingType)
    case contextMenu(ContextMenuSettingsPage)
    case postBarWidgetPicker(HashWrapper<Binding<PostBarConfiguration>>)
    case commentBarWidgetPicker(HashWrapper<Binding<CommentBarConfiguration>>)
    case replyBarWidgetPicker(HashWrapper<Binding<ReplyBarConfiguration>>)
    case postReportBarWidgetPicker(HashWrapper<Binding<PostBarConfiguration>>)
    case commentReportBarWidgetPicker(HashWrapper<Binding<CommentBarConfiguration>>)
    case moderation
    case modMailInteractionBar
    case separateModeratorActions
    case licences, document(Document)
    case cache

    static func contextMenu(_ keyPath: ReferenceWritableKeyPath<SettingsValues, some ContextMenuConfiguration>) -> Self {
        .contextMenu(.init(keyPath))
    }
    
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
        case .person:
            PersonSettingsView()
        case .instance:
            InstanceSettingsView()
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
        case .mediaAndLinks:
            MediaAndLinksSettingsView()
        case .externalLinks:
            ExternalLinkSettingsView()
        case .sharingLinks:
            SharingLinksSettingsView()
        case .tapFriendlyLinks:
            TapFriendlyLinksSettingsView()
        case .embedding:
            EmbeddingSettingsView()
        case .avatars:
            AvatarSettingsView()
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
        case .imageViewer:
            ImageViewerSettingsView()
        case .imageViewerControls:
            ImageViewerShowControlsSettingsView()
        case .imageViewerDismissSensitivity:
            ImageViewerDismissSettingsView()
        case let .swipeActions(type):
            switch type {
            case .post:
                SwipeActionEditorView(\.interactionBar_post, onApplyToAll: { configuration in
                    Settings.mutate(\.interactionBar_comment) {
                        $0.applying(other: configuration, types: [.swipe])
                    }
                    Settings.mutate(\.interactionBar_reply) {
                        $0.applying(other: configuration, types: [.swipe])
                    }
                })
            case .comment:
                SwipeActionEditorView(\.interactionBar_comment, onApplyToAll: { configuration in
                    Settings.mutate(\.interactionBar_post) {
                        $0.applying(other: configuration, types: [.swipe])
                    }
                    Settings.mutate(\.interactionBar_reply) {
                        $0.applying(other: configuration, types: [.swipe])
                    }
                })
            case .inboxNotification:
                SwipeActionEditorView(\.interactionBar_reply, onApplyToAll: { configuration in
                    Settings.mutate(\.interactionBar_post) {
                        $0.applying(other: configuration, types: [.swipe])
                    }
                    Settings.mutate(\.interactionBar_comment) {
                        $0.applying(other: configuration, types: [.swipe])
                    }
                })
            case .postReport:
                SwipeActionEditorView(\.interactionBar_postReport, onApplyToAll: { configuration in
                    Settings.mutate(\.interactionBar_commentReport) {
                        $0.applying(other: configuration, types: [.swipe])
                    }
                })
            case .commentReport:
                SwipeActionEditorView(\.interactionBar_commentReport, onApplyToAll: { configuration in
                    Settings.mutate(\.interactionBar_postReport) {
                        $0.applying(other: configuration, types: [.swipe])
                    }
                })
            case .community:
                SwipeActionEditorView(\.interactionBar_community, onApplyToAll: { configuration in
                    Settings.mutate(\.interactionBar_instance) {
                        $0.applySwipes(other: configuration)
                    }
                    Settings.mutate(\.interactionBar_community) {
                        $0.applySwipes(other: configuration)
                    }
                })
            case .person:
                SwipeActionEditorView(\.interactionBar_person, onApplyToAll: { configuration in
                    Settings.mutate(\.interactionBar_instance) {
                        $0.applySwipes(other: configuration)
                    }
                    Settings.mutate(\.interactionBar_community) {
                        $0.applySwipes(other: configuration)
                    }
                })
            case .instance:
                SwipeActionEditorView(\.interactionBar_instance, onApplyToAll: { configuration in
                    Settings.mutate(\.interactionBar_person) {
                        $0.applySwipes(other: configuration)
                    }
                    Settings.mutate(\.interactionBar_community) {
                        $0.applySwipes(other: configuration)
                    }
                })
            }
        case let .contextMenu(page):
            page.view
        case let .interactionBar(type):
            switch type {
            case .post:
                InteractionBarEditorView(setting: \.interactionBar_post, isReport: false)
            case .comment:
                InteractionBarEditorView(setting: \.interactionBar_comment, isReport: false)
            case .inboxNotification:
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
        case .cache:
            CacheSettingsView()
        case .errorToastTimeout:
            ErrorToastTimeoutSettingsView()
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

struct ContextMenuSettingsPage: Hashable {
    let view: AnyView
    let hash: Int

    init(_ keyPath: ReferenceWritableKeyPath<SettingsValues, some ContextMenuConfiguration>) {
        self.hash = keyPath.hashValue
        self.view = AnyView(ContextMenuSettingsView(keyPath))
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(hash)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
