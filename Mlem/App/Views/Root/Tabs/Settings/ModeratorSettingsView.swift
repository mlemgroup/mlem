//
//  ModeratorSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 01/10/2024.
//

import SwiftUI

struct ModeratorSettingsView: View {
    @Setting(\.moderatorActionGrouping) var moderatorActionGrouping
    
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
        }
        .navigationTitle("Moderation")
    }
}

enum ModeratorActionGrouping: String {
    case divider, disclosureGroup, separateMenu
}
