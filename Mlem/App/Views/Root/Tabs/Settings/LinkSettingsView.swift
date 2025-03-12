//
//  LinkSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 27/06/2024.
//

import SwiftUI

struct LinkSettingsView: View {
    @Setting(\.openLinksInBrowser) var openLinksInBrowser
    @Setting(\.openLinksInReaderMode) var openLinksInReaderMode
    @Setting(\.linkSharingMode) var linkSharingMode
    @Setting(\.tappableLinksDisplayMode) var tappableLinksDisplayMode
    @Setting(\.compactComments) var compactComments
    @Setting(\.embedLoops) var embedLoops
    @Setting(\.autoplayMedia) var autoplayMedia
    @Setting(\.muteVideos) var muteVideos

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Media & Links",
                description: "Manage how Mlem handles links and control how images and videos are displayed.",
                systemImage: "photo.fill"
            )
            .tint(.themedColorfulAccent(4))
            Section {
                NavigationLink(
                    "Open External Links",
                    value: .init(localized: externalLinksNavigationLinkValue),
                    fallbackValue: "",
                    systemImage: "arrow.up.right",
                    destination: .settings(.externalLinks)
                )
                NavigationLink(
                    "Share Links",
                    value: .init(localized: sharingLinksNavigationLinkValue),
                    fallbackValue: "",
                    systemImage: Icons.share,
                    destination: .settings(.sharingLinks)
                )
                NavigationLink(
                    "Tappable Links",
                    value: tappableLinksDisplayMode == .disabled ? "Off" : "On",
                    fallbackValue: "",
                    systemImage: "hand.tap",
                    destination: .settings(.tappableLinks)
                )
            }
            
            Section {
                if #available(iOS 18, *) {
                    Toggle("Autoplay", systemImage: Icons.playCircle, isOn: $autoplayMedia)
                }
                Toggle("Mute Videos", systemImage: Icons.muted, isOn: $muteVideos)
            }
            
            Section {
                NavigationLink(
                    "Embedded Content",
                    value: embedLoops ? "On" : "Off",
                    fallbackValue: "",
                    systemImage: Icons.embedding,
                    destination: .settings(.embedding)
                )
            }
        }
        .labelStyle(.conditional)
        .contentMargins(.top, 16)
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
        case .hostInstance: "Host Instance"
        case .askEveryTime: "Ask Every Time"
        }
    }
}
