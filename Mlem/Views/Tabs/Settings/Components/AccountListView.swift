//
//  AccountListView.swift
//  Mlem
//
//  Created by Sjmarf on 22/12/2023.
//

import SwiftUI
import Dependencies

enum AccountSortMode: String, CaseIterable {
    case name, instance, mostRecent
    
    var label: String {
        switch self {
        case .name:
            return "Name"
        case .instance:
            return "Instance"
        case .mostRecent:
            return "Most Recent"
        }
    }
    
    var systemImage: String {
        switch self {
        case .name:
            return "textformat"
        case .instance:
            return "at"
        case .mostRecent:
            return "clock"
        }
    }
}

struct AccountListView: View {
    @Dependency(\.accountsTracker) var accountsTracker: SavedAccountTracker
    @Environment(\.setAppFlow) private var setFlow
    
    @AppStorage("accountSort") private var accountSort: AccountSortMode = .name
    @AppStorage("groupAccountSort") private var groupAccountSort: Bool = false
    @EnvironmentObject var appState: AppState
    
    struct AccountGroup {
        let header: String
        let accounts: [SavedAccount]
    }
    
    var accounts: [SavedAccount] {
        switch accountSort {
        case .name:
            return accountsTracker.savedAccounts.sorted { $0.nicknameSortKey < $1.nicknameSortKey }
        case .instance:
            return accountsTracker.savedAccounts.sorted { $0.instanceSortKey < $1.instanceSortKey }
        case .mostRecent:
            return accountsTracker.savedAccounts.sorted {
                if appState.currentActiveAccount == $0 {
                    return true
                } else if appState.currentActiveAccount == $1 {
                    return true
                }
                return $0.lastUsed ?? .distantPast < $1.lastUsed ?? .distantPast
            }
        }
    }
    
    func getNameCategory(account: SavedAccount) -> String {
        guard let first = account.nickname.first else { return "Unknown" }
        if "abcdefghijklmnopqrstuvwxyz".contains(first) {
            return String(first)
        }
        return "*"
    }
    
    var accountGroups: [AccountGroup] {
        switch accountSort {
        case .name:
            return Dictionary(
                grouping: accountsTracker.savedAccounts,
                by: { getNameCategory(account: $0) }
            ).map { AccountGroup(header: $0, accounts: $1.sorted { $0.nicknameSortKey < $1.nicknameSortKey }) }
                .sorted { $0.header < $1.header }
        case .instance:
            let dict = Dictionary(
                grouping: accountsTracker.savedAccounts,
                by: { $0.instanceLink.host() ?? "Unknown" }
            )
            let uniqueInstances = dict.filter { $1.count == 1 }.values.map { $0.first! }
            var array = dict
                .filter { $1.count > 1 }
                .map { AccountGroup(header: $0, accounts: $1.sorted { $0.nicknameSortKey < $1.nicknameSortKey }) }
                .sorted { $0.header < $1.header }
            array.append(
                AccountGroup(
                    header: "Other",
                    accounts: uniqueInstances.sorted { $0.instanceSortKey < $1.instanceSortKey }
                )
            )
            return array
        case .mostRecent:
            var today = [SavedAccount]()
            var last30Days = [SavedAccount]()
            var older = [SavedAccount]()
            for account in accountsTracker.savedAccounts {
                if account == appState.currentActiveAccount {
                    continue
                }
                if let date = account.lastUsed {
                    if date.timeIntervalSinceNow <= 60 * 60 * 24 {
                        today.append(account)
                    } else if date.timeIntervalSinceNow <= 60 * 60 * 24 * 7 {
                        last30Days.append(account)
                    } else {
                        older.append(account)
                    }
                } else {
                    older.append(account)
                }
            }
            var groups = [AccountGroup]()
            if let currentActiveAccount = appState.currentActiveAccount {
                groups.append(AccountGroup(header: "", accounts: [currentActiveAccount]))
            }
            if !today.isEmpty {
                groups.append(AccountGroup(header: "Today", accounts: today))
            }
            if !last30Days.isEmpty {
                groups.append(AccountGroup(header: "Last 30 days", accounts: last30Days))
            }
            if !older.isEmpty {
                groups.append(AccountGroup(header: "Older", accounts: older))
            }
            return groups
        }
    }
    
    var body: some View {
        if groupAccountSort {
            ForEach(Array(accountGroups.enumerated()), id: \.offset) { offset, group in
                Section {
                    ForEach(group.accounts, id: \.self) { account in
                        AccountButtonView(
                            account: account,
                            caption: accountSort != .instance || group.header == "Other" ? .instanceAndTime : .timeOnly
                        )
                    }
                } header: {
                    HStack {
                        Text(group.header)
                        if offset == 0 {
                            sortDropDown
                        }
                    }
                }
            }
        } else {
            Section(header: sortDropDown) {
                ForEach(accounts, id: \.self) { account in
                    AccountButtonView(account: account)
                }
            }
        }
    }
    
    @ViewBuilder
    var sortDropDown: some View {
        HStack {
            Spacer()
            Menu {
                Picker("Sort", selection: $accountSort) {
                    ForEach(AccountSortMode.allCases, id: \.self) { sortMode in
                        Label(sortMode.label, systemImage: sortMode.systemImage).tag(sortMode)
                    }
                }
                Divider()
                Toggle(isOn: $groupAccountSort) {
                    Label("Grouped", systemImage: "square.stack.3d.up.fill")
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
}
