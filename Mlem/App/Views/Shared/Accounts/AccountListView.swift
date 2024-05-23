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
    @AppStorage("accountSort") var accountSort: AccountSortMode = .custom
    @AppStorage("groupAccountSort") var groupAccountSort: Bool = false
    
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.dismiss) var dismiss
    
    var accountsTracker: AccountsTracker { .main }
    
    @State private var isShowingInstanceAdditionSheet: Bool = false
    
    @State var isSwitching: Bool = false
    
    struct AccountGroup {
        let header: String
        let accounts: [Account]
    }
    
    let isQuickSwitcher: Bool
    
    init(isQuickSwitcher: Bool = false) {
        self.isQuickSwitcher = isQuickSwitcher
    }
    
    var shouldAllowReordering: Bool {
        (accountSort == .custom || accountsTracker.savedAccounts.count == 2) && !isQuickSwitcher
    }
    
    var body: some View {
        Group {
            if !isSwitching {
                if accountsTracker.savedAccounts.count > 3, groupAccountSort {
                    ForEach(Array(accountGroups.enumerated()), id: \.offset) { offset, group in
                        Section {
                            ForEach(group.accounts, id: \.self) { account in
                                AccountButtonView(
                                    account: account,
                                    caption: accountSort != .instance || group.header == "Other" ? .instanceAndTime : .timeOnly,
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
                } else if accounts.isEmpty {
                    Text("You don't have any accounts.")
                        .foregroundStyle(.secondary)
                } else {
                    Section(header: topHeader()) {
                        ForEach(accounts, id: \.self) { account in
                            AccountButtonView(account: account, isSwitching: $isSwitching)
                        }
                        .onMove(perform: shouldAllowReordering ? reorderAccount : nil)
                    }
                }
                Section {
                    Button {
                        navigation.openSheet(.login())
                    } label: {
                        Label("Add Account", systemImage: "plus")
                    }
                    .accessibilityLabel("Add a new account.")
                    Button {
                        appState.enterGuestMode(for: URL(string: "https://lemmy.world")!)
                        if navigation.isInsideSheet {
                            dismiss()
                        }
                    } label: {
                        Label("Enter Guest Mode", systemImage: Icons.person)
                    }
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
            if !isQuickSwitcher, accountsTracker.savedAccounts.count > 2 {
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
            if accountsTracker.savedAccounts.count > 3 {
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
            .foregroundStyle(.blue)
        }
        .textCase(nil)
    }
}
