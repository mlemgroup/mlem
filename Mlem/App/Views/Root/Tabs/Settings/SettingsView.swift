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
    
    @AppStorage("upvoteOnSave") var upvoteOnSave = false
    
    var accounts: [UserAccount] { AccountsTracker.main.savedAccounts }
    
    var body: some View {
        Form {
            Section {
                accountSettingsLink
                accountListLink
            }
            Section {
                NavigationLink("Theme", destination: .settings(.theme))
            }
            Section {
                Toggle("Upvote On Save", isOn: $upvoteOnSave)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var accountSettingsLink: some View {
        NavigationLink(.settings(.account)) {
            let account = appState.firstAccount
            HStack(spacing: 23) {
                AvatarView(account.account)
                    .frame(width: 54)
                    .padding(.vertical, -6)
                    .padding(.leading, 3)
                VStack(alignment: .leading, spacing: 3) {
                    Text(account is ActiveUserAccount ? account.account.nickname : "Guest")
                        .font(.title2)
                    Text(accountSettingsLinkSubtitle)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                Spacer()
            }
        }
    }
    
    var accountSettingsLinkSubtitle: String {
        let account = appState.firstAccount
        if let host = account.account.host {
            return "@\(host)"
        }
        return ""
    }
    
    var accountListLink: some View {
        NavigationLink(.settings(.accounts)) {
            HStack(spacing: 10) {
                AvatarStackView(
                    urls: accounts.prefix(4).map(\.avatar),
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
