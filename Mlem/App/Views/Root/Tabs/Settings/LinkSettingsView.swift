//
//  LinkSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 27/06/2024.
//

import SwiftUI

struct LinkSettingsView: View {
    @Environment(Palette.self) var palette
    @Setting(\.openLinksInBrowser) var openLinksInBrowser
    @Setting(\.openLinksInReaderMode) var openLinksInReaderMode
    @Setting(\.compactComments) var compactComments
    @Setting(\.tappableLinksDisplayMode) var tappableLinksDisplayMode
    @Setting(\.embedLoops) var embedLoops
    @Setting(\.autoplayMedia) var autoplayMedia
    @Setting(\.muteVideos) var muteVideos

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Media & Links",
                description: "Manage how Mlem handles links and control how images and videos are displayed.",
                systemImage: "photo.on.rectangle.angled.fill"
            )
            .tint(palette.colorfulAccent(4))
            Section {
                NavigationLink(
                    "Open External Links",
                    value: "In Browser",
                    fallbackValue: "",
                    destination: .settings(.links)
                )
                NavigationLink(
                    "Tappable Links",
                    value: "On",
                    fallbackValue: "",
                    destination: .settings(.links)
                )
            }
            
            Section {
                Toggle("Autoplay", systemImage: Icons.playCircle, isOn: $autoplayMedia)
                Toggle("Mute Videos", systemImage: Icons.muted, isOn: $muteVideos)
            }
            
            Section {
                NavigationLink(
                    "Embedded Content",
                    value: "On",
                    fallbackValue: "",
                    destination: .settings(.links)
                )
            }
//            Section("Open External Links") {
//                Picker("Open External Links", selection: $openLinksInBrowser) {
//                    Label("In-App", systemImage: Icons.inApp).tag(false)
//                    Label("In Default Browser", systemImage: Icons.browser).tag(true)
//                }
//                .pickerStyle(.inline)
//                .labelsHidden()
//            }
//
//            Section {
//                Toggle("Open in Reader", systemImage: Icons.reader, isOn: $openLinksInReaderMode)
//                    .disabled(openLinksInBrowser)
//            } footer: {
//                Text("Automatically enable Reader for supported webpages. You can only enable this when using the in-app browser.")
//            }
//
//            Section {
//                Toggle(
//                    "Tappable Links",
//                    systemImage: Icons.websiteAddress,
//                    isOn: Binding(
//                        get: { tappableLinksDisplayMode != .disabled },
//                        set: { newValue in
//                            withAnimation(.easeOut(duration: 0.1)) {
//                                tappableLinksDisplayMode = newValue ? .large : .disabled
//                            }
//                        }
//                    )
//                )
//                if tappableLinksDisplayMode != .disabled {
//                    Picker("Show Full URL", systemImage: Icons.inlineCode, selection: $tappableLinksDisplayMode) {
//                        Text("Automatic").tag(TappableLinksDisplayMode.contextual)
//                        Text("Always").tag(TappableLinksDisplayMode.large)
//                        Text("Never").tag(TappableLinksDisplayMode.compact)
//                    }
//                    .pickerStyle(.menu)
//                }
//            } footer: {
//                if tappableLinksDisplayMode != .disabled {
//                    Text("If set to \"Automatic\", the full URL will be hidden in compact comments.")
//                }
//            }
//
//            NavigationLink("Embeddings", systemImage: Icons.embedding, destination: .settings(.embedding))
        }
        .labelStyle(.conditional)
        .contentMargins(.top, 16)
    }
}
