//
//  ContentView+Tab.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-23.
//

import Foundation
import Icons
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
        
        var icon: Icon {
            switch self {
            case .feeds: .lemmy.feed
            case .inbox: .lemmy.inbox
            case .profile: .lemmy.personAvatar
            case .search: .general.search
            case .settings: .general.settings
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
        @ViewBuilder content: () -> some View
    ) {
        self.init(
            title: tab.label(appState: appState, profileLabelType: profileLabelType),
            image: imageOverride ?? .init(icon: tab.icon.representingState(active: false)),
            selectedImage: selectedImageOverride ?? .init(icon: tab.icon.representingState(active: true)),
            badge: badge,
            content: content
        )
    }
}
