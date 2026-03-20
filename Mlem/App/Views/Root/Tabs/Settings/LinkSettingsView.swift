//
//  LinkSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 27/06/2024.
//

import SwiftUI
import Theming

struct LinkSettingsView: View {
    @Setting(\.links_openInBrowser) var openLinksInBrowser
    @Setting(\.links_readerMode) var openLinksInReaderMode
    @Setting(\.links_shareMode) var linkSharingMode
    @Setting(\.links_displayMode) var tappableLinksDisplayMode
    @Setting(\.comment_compact) var compactComments
    @Setting(\.links_embedLoops) var embedLoops
    @Setting(\.behavior_autoplayMedia) var autoplayMedia
    @Setting(\.behavior_muteVideos) var muteVideos

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Media & Links",
                description: "Manage how Mlem handles links and control how images and videos are displayed.",
                icon: .general.image
            )
            .gradientTint(.themedColorfulAccent(4))
            Section {
                NavigationLink(
                    "Open External Links",
                    value: .init(localized: externalLinksNavigationLinkValue),
                    fallbackValue: "",
                    icon: .settings.openExternalLinks,
                    destination: .settings(.externalLinks)
                )
                NavigationLink(
                    "Share Links",
                    value: .init(localized: sharingLinksNavigationLinkValue),
                    fallbackValue: "",
                    icon: .general.share,
                    destination: .settings(.sharingLinks)
                )
                NavigationLink(
                    "Tappable Links",
                    value: tappableLinksDisplayMode == .disabled ? "Off" : "On",
                    fallbackValue: "",
                    icon: .settings.tappableLinks,
                    destination: .settings(.tappableLinks)
                )
            }

            Section {
                NavigationLink(
                    "Image Viewer",
                    icon: .settings.imageViewer,
                    destination: .settings(.imageViewer)
                )
            }
            
            Section {
                Toggle("Autoplay", icon: .general.playCircle, isOn: $autoplayMedia)
                Toggle("Mute Videos", icon: .general.muted, isOn: $muteVideos)
            }
            
            Section {
                NavigationLink(
                    "Embedded Content",
                    value: embedLoops ? "On" : "Off",
                    fallbackValue: "",
                    icon: .general.embedding,
                    destination: .settings(.embedding)
                )
            }
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Media & Links")
    }
    
    var externalLinksNavigationLinkValue: LocalizedStringResource {
        if openLinksInBrowser {
            "In Browser"
        } else {
            openLinksInReaderMode ? "In Reader" : "In Mlem"
        }
    }
    
    var sharingLinksNavigationLinkValue: LocalizedStringResource {
        switch linkSharingMode {
        case .myInstance: "My Instance"
        case .originalInstance: "Original Instance"
        case .lemmyverse: "Universal"
        case .askEveryTime: "Ask Every Time"
        }
    }
}
