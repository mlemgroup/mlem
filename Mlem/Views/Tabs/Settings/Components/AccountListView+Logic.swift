//
//  AccountListView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 22/12/2023.
//

import SwiftUI

extension AccountListView {
    var accounts: [SavedAccount] {
        let accountSort = accountsTracker.savedAccounts.count == 2 ? .custom : accountSort
        switch accountSort {
        case .custom:
            return accountsTracker.savedAccounts
        case .name:
            return accountsTracker.savedAccounts.sorted { $0.nicknameSortKey < $1.nicknameSortKey }
        case .instance:
            return accountsTracker.savedAccounts.sorted { $0.instanceSortKey < $1.instanceSortKey }
        case .mostRecent:
            return accountsTracker.savedAccounts.sorted {
                if appState.currentActiveAccount == $0 {
                    return true
                } else if appState.currentActiveAccount == $1 {
                    return false
                }
                return $0.lastUsed ?? .distantPast > $1.lastUsed ?? .distantPast
            }
        }
    }
    
    func getNameCategory(account: SavedAccount) -> String {
        guard let first = account.nickname.first else { return "Unknown" }
        if first.isLetter {
            return String(first.lowercased())
        }
        return "*"
    }
    
    var accountGroups: [AccountGroup] {
        switch accountSort {
        case .custom:
            return [.init(header: "Custom", accounts: accountsTracker.savedAccounts)]
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
                
                var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: .now)
                dateComponents.hour = 0
                dateComponents.minute = 0
                dateComponents.second = 0
                let todayDate = Calendar.current.date(from: dateComponents) ?? .distantFuture
                
                if let date = account.lastUsed {
                    if date > todayDate {
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
                today.prepend(currentActiveAccount)
            }
            if !today.isEmpty {
                groups.append(
                    AccountGroup(
                        header: "Today",
                        accounts: today.sorted { $0.lastUsed ?? .distantPast > $1.lastUsed ?? .distantPast }
                    )
                )
            }
            if !last30Days.isEmpty {
                groups.append(
                    AccountGroup(
                        header: "Last 30 days",
                        accounts: last30Days.sorted { $0.lastUsed ?? .distantPast > $1.lastUsed ?? .distantPast }
                    )
                )
            }
            if !older.isEmpty {
                groups.append(
                    AccountGroup(
                        header: "Older",
                        accounts: older.sorted { $0.lastUsed ?? .distantPast > $1.lastUsed ?? .distantPast }
                    )
                )
            }
            return groups
        }
    }
    
    func reorderAccount(fromOffsets: IndexSet, toOffset: Int) {
        accountsTracker.savedAccounts.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }
}
