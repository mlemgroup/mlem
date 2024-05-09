//
//  SettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 07/05/2024.
//

import MlemMiddleware
import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    var accounts: [UserStub] { AccountsTracker.main.savedAccounts }
    
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
        NavigationLink(.settings(.account)) {
            let account = appState.firstAccount
            HStack(spacing: 23) {
                AvatarView(account.userStub)
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
        NavigationLink(.settings(.accounts)) {
            HStack(spacing: 10) {
                AvatarStackView(
                    urls: accounts.prefix(4).map(\.avatarUrl),
                    type: .person,
                    spacing: accounts.count <= 3 ? 18 : 14,
                    outlineWidth: 0.7,
                    showPlusIcon: accounts.count == 1
                )
                .frame(height: 28)
                .frame(minWidth: 80)
                .padding(.leading, -10)
                Text("Accounts")
                Spacer()
                Text("\(accounts.count)")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
