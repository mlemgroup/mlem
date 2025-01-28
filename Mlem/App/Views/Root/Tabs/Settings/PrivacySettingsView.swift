//
//  PrivacySettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-25.
//

import SwiftUI

struct PrivacySettingsView: View {
    @Environment(Palette.self) var palette
    
    @Setting(\.autoBypassImageProxy) var bypassImageProxy
    @Setting(\.confirmImageUploads) var confirmImageUploads
    @Setting(\.showFavicons) var showFavicons

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Privacy",
                description: "Manage how Mlem interacts with Lemmy instances and other websites.",
                systemImage: Icons.privacy
            )
            .tint(palette.colorfulAccent(2))
            Section {
                Toggle("Confirm Image Uploads", systemImage: Icons.confirmImageUploads, isOn: $confirmImageUploads)
            } footer: {
                Text("When enabled, Mlem will ask you to confirm your choice before uploading an image to your instance.")
            }
            Section {
                NavigationLink(
                    "Bypass Image Proxy",
                    value: .init(localized: bypassImageProxyNavigationLinkValue),
                    fallbackValue: "",
                    systemImage: Icons.proxy,
                    destination: .settings(.privacyBypassImageProxy)
                )
            }
            Section {
                Toggle("Hide Website Icons", systemImage: "camera.macro.circle", isOn: $showFavicons.invert())
            } footer: {
                Text("Mlem uses a Google API to fetch website icon URLs. If you'd prefer not to use this, you can choose to hide favicons.")
            }
            Section {
                NavigationLink(
                    "Mlem Privacy Policy",
                    systemImage: Icons.privacy,
                    destination: .settings(.document(.privacyPolicy))
                )
            }
        }
        .labelStyle(.conditional)
        .contentMargins(.top, 16)
    }
    
    var bypassImageProxyNavigationLinkValue: LocalizedStringResource {
        bypassImageProxy ? "Automatically" : "Ask First"
    }
}
