//
//  AccountListView.swift
//  Mlem
//
//  Created by Sjmarf on 22/12/2023.
//

import MlemMiddleware
import SwiftUI

/// This view is a component used as a child of ``QuickSwitcherView`` and ``AccountListSettingsView``.
struct AccountListView: View {
    @Setting(\.accountSort) var accountSort
    @Setting(\.groupAccountSort) var groupAccountSort
    
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    var accountsTracker: AccountsTracker { .main }
    
    @State var isSwitching: Bool = false
    
    @State private var isShowingAddAccountDialogue: Bool = false
    
    struct AccountGroup {
        let header: String
        let accounts: [any Account]
    }
    
    let isQuickSwitcher: Bool
    
    init(isQuickSwitcher: Bool = false) {
        self.isQuickSwitcher = isQuickSwitcher
    }
    
    var shouldAllowReordering: Bool {
        (accountSort == .custom || accountsTracker.userAccounts.count == 2) && !isQuickSwitcher
    }
    
    var body: some View {
        if !isSwitching {
            if accountsTracker.userAccounts.count > 3, groupAccountSort {
                groupedUserAccountList
            } else if accounts.isEmpty {
                Text("You don't have any accounts.")
                    .foregroundStyle(palette.secondary)
            } else {
                Section {
                    ForEach(accounts, id: \.actorId) { account in
                        AccountListRow(account: account, isSwitching: $isSwitching)
                    }
                    .onMove(perform: shouldAllowReordering ? reorderAccount : nil)
                } header: {
                    topHeader()
                }
            }
            if let account = (appState.firstSession as? GuestSession)?.account, !account.isSaved {
                Section {
                    AccountListRow(account: account, isSwitching: $isSwitching)
                }
            }
            Section {
                ForEach(accountsTracker.guestAccounts, id: \.actorId) { account in
                    AccountListRow(
                        account: account,
                        complications: .withTime,
                        isSwitching: $isSwitching
                    )
                }
            }
            addAccountButton
        }
    }
    
    @ViewBuilder
    var groupedUserAccountList: some View {
        ForEach(Array(accountGroups.enumerated()), id: \.offset) { offset, group in
            Section {
                ForEach(group.accounts, id: \.actorId) { account in
                    AccountListRow(
                        account: account,
                        complications: accountSort != .instance || group.header == "Other" ? .withTime : .timeOnly,
                        isSwitching: $isSwitching
                    )
                }
            } header: {
                if offset == 0 {
                    topHeader(text: group.header)
                } else {
                    Text(group.header)
                }
            }
        }
    }
    
    @ViewBuilder
    var addAccountButton: some View {
        Section {
            Button { isShowingAddAccountDialogue = true } label: {
                Label("Add Account", systemImage: "plus")
            }
            .confirmationDialog("Choose Account Type", isPresented: $isShowingAddAccountDialogue) {
                Button("Log In") {
                    navigation.openSheet(.logIn())
                }
                Button("Sign Up") {
                    navigation.openSheet(.signUp())
                }
                Button("Add Guest") {
                    navigation.openSheet(.instancePicker(callback: { instance in
                        if let url = URL(string: "https://\(instance.host)") {
                            if let guest = try? GuestAccount.getGuestAccount(url: url) {
                                if !guest.isSaved {
                                    AccountsTracker.main.addAccount(account: guest)
                                }
                                AppState.main.changeAccount(to: guest)
                                if navigation.isInsideSheet {
                                    dismiss()
                                }
                            }
                        }
                    }))
                }
            }
        }
    }
    
    @ViewBuilder
    func topHeader(text: String? = nil) -> some View {
        HStack {
            if let text {
                Text(text)
            }
            if !isQuickSwitcher, accountsTracker.userAccounts.count > 2 {
                Spacer()
                sortModeMenu()
            }
        }
    }
    
    @ViewBuilder
    func sortModeMenu() -> some View {
        Menu {
            Picker("Sort", selection: $accountSort) {
                ForEach(AccountSortMode.allCases, id: \.self) { sortMode in
                    Label(sortMode.label, systemImage: sortMode.systemImage).tag(sortMode)
                }
            }
            .onChange(of: accountSort) {
                if accountSort == .custom {
                    groupAccountSort = false
                }
            }
            if accountsTracker.userAccounts.count > 3 {
                Divider()
                Toggle(isOn: $groupAccountSort) {
                    Label("Grouped", systemImage: "square.stack.3d.up.fill")
                }
                .disabled(accountSort == .custom)
            }
        } label: {
            HStack(alignment: .center, spacing: 2) {
                Text("Sort by: \(accountSort.label)")
                    .font(.caption)
                    .textCase(nil)
                Image(systemName: "chevron.down")
                    .imageScale(.small)
            }
            .fontWeight(.semibold)
            .foregroundStyle(palette.accent)
        }
        .textCase(nil)
    }
}
