//
//  ModeratorSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 01/10/2024.
//

import SwiftUI

struct ModeratorSettingsView: View {
    @Setting(\.moderatorActionGrouping) var moderatorActionGrouping
    @Setting(\.showAllModActions) var showAllModActions
    
    var body: some View {
        Form {
            Section {
                Picker("Group actions using", selection: $moderatorActionGrouping) {
                    Text("Divider")
                        .tag(ModeratorActionGrouping.divider)
                    Text("Disclosure Group")
                        .tag(ModeratorActionGrouping.disclosureGroup)
                    Text("Separate Menu")
                        .tag(ModeratorActionGrouping.separateMenu)
                }
                .pickerStyle(.inline)
                .labelsHidden()
            } header: {
                Text("Separate moderator actions using...")
                    .textCase(nil)
            }
            Section {
                Toggle("Show All Actions in Feed", isOn: $showAllModActions)
            } footer: {
                // swiftlint:disable:next line_length
                Text("When disabled, some moderator actions will be hidden from the feed and will only be visible from when viewing a post page.")
            }
        }
        .navigationTitle("Moderation")
    }
}

enum ModeratorActionGrouping: String, Codable {
    case divider, disclosureGroup, separateMenu
    
    init?(rawValue: String) {
        switch rawValue {
        // Decode v1 case
        case "none", "divider":
            self = .divider
        case "disclosureGroup":
            self = .disclosureGroup
        case "separateMenu":
            self = .separateMenu
        default:
            return nil
        }
    }
}
