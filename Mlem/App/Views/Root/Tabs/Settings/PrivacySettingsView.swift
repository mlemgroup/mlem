//
//  PrivacySettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-25.
//

import SwiftUI

struct PrivacySettingsView: View {
    @Setting(\.privacy_autoBypassImageProxy) var bypassImageProxy
    @Setting(\.behavior_confirmImageUploads) var confirmImageUploads
    @Setting(\.post_webPreview_showIcon) var showFavicons

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Privacy",
                description: "Manage how Mlem interacts with Lemmy instances and other websites.",
                icon: .settings.privacy
            )
            .tint(.themedColorfulAccent(2))
            Section {
                Toggle("Confirm Image Uploads", icon: .settings.confirmImageUploads, isOn: $confirmImageUploads)
            } footer: {
                Text("When enabled, Mlem will ask you to confirm your choice before uploading an image to your instance.")
            }
            Section {
                NavigationLink(
                    "Bypass Image Proxy",
                    value: .init(localized: bypassImageProxyNavigationLinkValue),
                    fallbackValue: "",
                    icon: .lemmy.imageProxy,
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
                    icon: .settings.privacy,
                    destination: .settings(.document(.privacyPolicy))
                )
            }
        }
        .labelStyle(.conditional)
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Privacy")
    }
    
    var bypassImageProxyNavigationLinkValue: LocalizedStringResource {
        bypassImageProxy ? "Automatically" : "Ask First"
    }
}
