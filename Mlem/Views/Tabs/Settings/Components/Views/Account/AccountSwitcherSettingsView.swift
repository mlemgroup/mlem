//
//  AccountSwitcherSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 22/12/2023.
//

import SwiftUI
import Dependencies

struct AccountSwitcherSettingsView: View {
    @Dependency(\.accountsTracker) var accountsTracker: SavedAccountTracker
    
    var body: some View {
        Form {
            Section {
                VStack {
                    AccountIconStack(
                        accounts: Array(accountsTracker.savedAccounts.prefix(7)),
                        avatarSize: 64,
                        spacing: 32,
                        outlineWidth: 2.6,
                        backgroundColor: Color(UIColor.systemGroupedBackground)
                    )
                    .padding(.top, -12)
                    Text("Accounts")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color(.systemGroupedBackground))
            }
            AccountListView()
        }
        .fancyTabScrollCompatible()
    }
    
}
