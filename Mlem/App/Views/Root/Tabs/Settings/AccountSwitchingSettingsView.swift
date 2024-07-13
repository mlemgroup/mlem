//
//  AccountSwitchingSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 12/07/2024.
//

import SwiftUI

struct AccountSwitchingSettingsView: View {
    @Environment(AppState.self) var appState
    
    @AppStorage("accounts.keepPlace") var keepPlace: Bool = false
    @AppStorage("accounts.keepPlace.reloadFeed") var reloadFeed: Bool = true
    
    var accountSwitchModeBinding: Binding<Int> {
        .init(get: {
            switch (keepPlace, reloadFeed) {
            case (false, _):
                1
            case (true, true):
                2
            case (true, false):
                3
            }
        }, set: { newValue in
            switch newValue {
            case 1:
                keepPlace = false
                reloadFeed = false
            case 2:
                keepPlace = true
                reloadFeed = true
            default:
                keepPlace = true
                reloadFeed = false
            }
        })
    }
    
    var body: some View {
        Form {
            Section("When I switch accounts...") {
                Picker("When I switch accounts", selection: accountSwitchModeBinding) {
                    Text("Refresh App").tag(1)
                    Text("Refresh Feeds Only").tag(2)
                    Text("Don't Refresh").tag(3)
                }
                .pickerStyle(.inline)
            }
            .labelsHidden()
        }
    }
}
