//
//  SettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 07/05/2024.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    var body: some View {
        Form {
            Section {
                accountSettingsLink()
                accountListLink()
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    func accountSettingsLink() -> some View {
        NavigationLink(.settings(.accounts)) {
            let account = appState.firstAccount
            HStack(spacing: 23) {
                AvatarView(
                    url: account.userStub?.avatarUrl,
                    type: .person
                )
                .frame(width: 54)
                .padding(.vertical, -6)
                .padding(.leading, 3)
                VStack(alignment: .leading, spacing: 3) {
                    Text(account.userStub?.nickname ?? account.userStub?.name ?? "")
                        .font(.title2)
                    if let hostName = account.userStub?.api.baseUrl.host() {
                        Text("@\(hostName)")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    func accountListLink() -> some View {
        switch AccountsTracker.main.savedAccounts.count {
        case 0:
            Button("Sign In") { navigation.openSheet(.addAccount) }
        case 1:
            Button("Add Another Account") { navigation.openSheet(.addAccount) }
        default:
            NavigationLink("Accounts", destination: .settings(.accounts))
        }
    }
}
