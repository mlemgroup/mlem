//
//  PrivacySettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-25.
//

import SwiftUI
import Theming

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
            .tint(ThemedColor.themedColorfulAccent(2).gradient)
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
                // swiftlint:disable:next line_length
                Text("Mlem uses a Google API to fetch website icon URLs. If you'd prefer not to use this, you can choose to hide website icons.")
            }
            Section {
                NavigationLink(
                    "Mlem Privacy Policy",
                    icon: .settings.privacy,
                    destination: .settings(.document(.privacyPolicy))
                )
            }
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Privacy")
    }
    
    var bypassImageProxyNavigationLinkValue: LocalizedStringResource {
        bypassImageProxy ? "Automatically" : "Ask First"
    }
}
