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
    
    @State private var isShowingInstanceAdditionSheet: Bool = false
    
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
            Section {
                Button {
                    isShowingInstanceAdditionSheet = true
                } label: {
                    Label("Add Account", systemImage: "plus")
                }
                .accessibilityLabel("Add a new account.")
            }
        }
        .sheet(isPresented: $isShowingInstanceAdditionSheet) {
            AddSavedInstanceView(onboarding: false)
        }
        .fancyTabScrollCompatible()
    }
    
}
