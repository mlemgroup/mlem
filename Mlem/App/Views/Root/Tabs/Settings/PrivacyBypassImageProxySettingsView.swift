//
//  PrivacyBypassImageProxySettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-25.
//

import SwiftUI

struct PrivacyBypassImageProxySettingsView: View {
    @Setting(\.privacy_autoBypassImageProxy) var bypassImageProxy
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Bypass Image Proxy",
                // swiftlint:disable:next line_length
                description: "Some instances proxy images to protect your privacy. In certain cases, this causes image loading to fail. You can bypass the image proxy and load directly, but this will expose your IP address to the image host.",
                icon: .lemmy.imageProxy
            )
            .tint(.themedColorfulAccent(4))
            Section("Bypass Image Proxy...") {
                Picker("Bypass Image Proxy", selection: $bypassImageProxy) {
                    Label("Automatically", icon: .general.success)
                        .symbolVariant(.circle)
                        .tag(true)
                    Label("Ask First", systemImage: "questionmark.circle")
                        .tag(false)
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
        }
        .contentMargins(.top, 16)
        .labelStyle(.conditional)
        .hiddenNavigationTitle("Bypass Image Proxy")
    }
}
