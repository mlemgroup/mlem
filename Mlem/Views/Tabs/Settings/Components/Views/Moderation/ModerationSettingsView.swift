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
    @AppStorage("showSettingsIcons") var showSettingsIcons: Bool = true
    
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
            
            Section {
                NavigationLink(.moderationSettings(.customizeWidgets)) {
                    Label {
                        Text("Customize Widgets")
                    } icon: {
                        if showSettingsIcons {
                            Image(systemName: Icons.widgetWizard)
                                .foregroundColor(.pink)
                        }
                    }
                }
            } footer: {
                Text("Customize the widgets shown on Mod Mail reports.")
            }
            
            Section("Separate moderator actions using...") {
                Picker("Group actions using", selection: $moderatorActionGrouping) {
                    Text("Divider")
                        .tag(ModerationActionGroupingMode.none)
                    Text("Disclosure Group")
                        .tag(ModerationActionGroupingMode.disclosureGroup)
                    Text("Separate Menu")
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
