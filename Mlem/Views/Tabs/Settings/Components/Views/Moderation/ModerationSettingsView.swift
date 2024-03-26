//
//  ModerationSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 25/03/2024.
//

import Dependencies
import SwiftUI

enum ModerationActionGroupingMode: String {
    case none, disclosureGroup, separateMenu
}

struct ModerationSettingsView: View {
    @Dependency(\.siteInformation) var siteInformation
    
    @AppStorage("showAllModeratorActions") var showAllModeratorActions: Bool = false
    @AppStorage("moderatorActionGrouping") var moderatorActionGrouping: ModerationActionGroupingMode = .none
    
    var body: some View {
        Form {
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.moderation,
                    settingName: "Show All Actions in Feed",
                    isTicked: $showAllModeratorActions
                )
            } footer: {
                Text(
                    // swiftlint:disable:next line_length
                    "When disabled, some moderator actions will be hidden from the feed and will only be visible from when viewing a post page."
                )
            }
            Section("Separate moderator actions using...") {
                let plural = siteInformation.isAdmin
                Picker("Group actions using", selection: $moderatorActionGrouping) {
                    Text(plural ? "Dividers" : "Divider")
                        .tag(ModerationActionGroupingMode.none)
                    Text(plural ? "Disclosure Groups" : "Disclosure Group")
                        .tag(ModerationActionGroupingMode.disclosureGroup)
                    Text(plural ? "Separate Menus" : "Separate Menu")
                        .tag(ModerationActionGroupingMode.separateMenu)
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Moderation")
        .navigationBarColor()
        .hoistNavigation()
    }
}
