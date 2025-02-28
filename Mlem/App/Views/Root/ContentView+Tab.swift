//
//  ContentView+Tab.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-23.
//

import Foundation
import SwiftUI

extension ContentView {
    enum Tab: CaseIterable {
        case feeds, inbox, profile, search, settings
        
        var defaultLabel: LocalizedStringResource {
            switch self {
            case .feeds: "Feeds"
            case .inbox: "Inbox"
            case .profile: "Profile"
            case .search: "Search"
            case .settings: "Settings"
            }
        }
        
        func label(appState: AppState, profileLabelType: ProfileTabLabel) -> String {
            switch self {
            case .profile:
                switch profileLabelType {
                case .nickname:
                    appState.firstAccount.nickname
                case .instance:
                    appState.firstAccount.host
                case .anonymous:
                    .init(localized: "Profile")
                }
            default:
                .init(localized: defaultLabel)
            }
        }
        
        var systemImage: String {
            switch self {
            case .feeds: Icons.feeds
            case .inbox: Icons.inbox
            case .profile: Icons.personCircle
            case .search: Icons.search
            case .settings: Icons.settings
            }
        }
        
        var systemImageFill: String {
            switch self {
            case .feeds: Icons.feedsFill
            case .inbox: Icons.inboxFill
            case .profile: Icons.personCircleFill
            case .search: Icons.searchActive
            case .settings: Icons.settings
            }
        }
    }
}

extension CustomTabItem {
    init(
        _ tab: ContentView.Tab,
        appState: AppState,
        profileLabelType: ProfileTabLabel,
        imageOverride: UIImage? = nil,
        selectedImageOverride: UIImage? = nil,
        badge: String? = nil,
        onLongPress: (() -> Void)? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.init(
            title: tab.label(appState: appState, profileLabelType: profileLabelType),
            image: imageOverride ?? .init(systemName: tab.systemImage),
            selectedImage: selectedImageOverride ?? .init(systemName: tab.systemImageFill),
            badge: badge,
            onLongPress: onLongPress, content: content
        )
    }
}
