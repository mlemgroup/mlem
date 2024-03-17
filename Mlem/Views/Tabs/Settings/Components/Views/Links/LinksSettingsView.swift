//
//  LinksSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 17/03/2024.
//

import SwiftUI

struct LinksSettingsView: View {
    @AppStorage("openLinksInBrowser") var openLinksInBrowser: Bool = false
    @AppStorage("openLinksInReaderMode") var openLinksInReaderMode: Bool = false
    @AppStorage("easyTapLinkDisplayMode") var easyTapLinkDisplayMode: EasyTapLinkDisplayMode = .contextual
    
    var body: some View {
        Form {
            Section("Open External Links") {
                Picker("Open External Links", selection: $openLinksInBrowser) {
                    Text("In-App").tag(false)
                    Text("In Default Browser").tag(true)
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: "doc.plaintext",
                    settingName: "Open in Reader",
                    isTicked: Binding(
                        get: {
                            !openLinksInBrowser && openLinksInReaderMode
                        },
                        set: { newValue in
                            openLinksInReaderMode = newValue
                        }
                    )
                )
                .disabled(openLinksInBrowser)
            } footer: {
                Text("Automatically enable Reader for supported webpages. You can only enable this when using the in-app browser.")
            }
            Section {
                SelectableSettingsItem(
                    settingIconSystemName: Icons.websiteAddress,
                    settingName: "Tappable Links",
                    currentValue: $easyTapLinkDisplayMode,
                    options: EasyTapLinkDisplayMode.allCases
                )
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Links")
        .navigationBarColor()
        .hoistNavigation()
    }
}
