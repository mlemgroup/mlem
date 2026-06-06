//
//  AccountListView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 22/12/2023.
//

import MlemMiddleware
import SwiftUI

extension AccountListView {
    var accounts: [any Account] {
        let accountSort = accountsTracker.userAccounts.count == 2 ? .custom : accountSort
        switch accountSort {
        case .custom:
            return accountsTracker.userAccounts
        case .name:
            return accountsTracker.userAccounts.sorted { $0.nicknameSortKey < $1.nicknameSortKey }
        case .instance:
            return accountsTracker.userAccounts.sorted { $0.instanceSortKey < $1.instanceSortKey }
        case .mostRecent:
            return accountsTracker.userAccounts.sorted { left, right in
                if appState.firstSession.actorId == left.actorId {
                    return true
                } else if appState.firstSession.actorId == right.actorId {
                    return false
                }
                return left.activityState.lastUsed ?? .distantPast > right.activityState.lastUsed ?? .distantPast
            }
        }
    }
    
    func getNameCategory(account: any Account) -> String {
        guard let first = account.nickname.first else { return "Unknown" }
        if first.isLetter {
            return String(first.lowercased())
        }
        return "*"
    }
    
    var accountGroups: [AccountGroup] {
        switch accountSort {
        case .custom:
            return [.init(header: "Custom", accounts: accountsTracker.userAccounts)]
        case .name:
            return Dictionary(
                grouping: accountsTracker.userAccounts,
                by: { getNameCategory(account: $0) }
            ).map { AccountGroup(header: $0, accounts: $1.sorted { $0.nicknameSortKey < $1.nicknameSortKey }) }
                .sorted { $0.header < $1.header }
        case .instance:
            let dict = Dictionary(
                grouping: accountsTracker.userAccounts,
                by: \.host
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
            var today = [any Account]()
            var last30Days = [any Account]()
            var older = [any Account]()
            for account in accountsTracker.userAccounts {
                if account.actorId == appState.firstSession.actorId {
                    continue
                }
                
                var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: .now)
                dateComponents.hour = 0
                dateComponents.minute = 0
                dateComponents.second = 0
                let todayDate = Calendar.current.date(from: dateComponents) ?? .distantFuture
                
                if let date = account.activityState.lastUsed {
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
            
            today.sort { $0.activityState.lastUsed ?? .distantPast > $1.activityState.lastUsed ?? .distantPast }
            today.prepend(appState.firstSession.account)
            
            if !today.isEmpty {
                groups.append(
                    AccountGroup(
                        header: "Today",
                        accounts: today
                    )
                )
            }
            if !last30Days.isEmpty {
                groups.append(
                    AccountGroup(
                        header: "Last \(30) days",
                        accounts: last30Days.sorted {
                            $0.activityState.lastUsed ?? .distantPast > $1.activityState.lastUsed ?? .distantPast
                        }
                    )
                )
            }
            if !older.isEmpty {
                groups.append(
                    AccountGroup(
                        header: "Older",
                        accounts: older.sorted {
                            $0.activityState.lastUsed ?? .distantPast > $1.activityState.lastUsed ?? .distantPast
                        }
                    )
                )
            }
            return groups
        }
    }
    
    func reorderAccount(fromOffsets: IndexSet, toOffset: Int) {
        accountsTracker.userAccounts.move(fromOffsets: fromOffsets, toOffset: toOffset)
        accountsTracker.saveAccounts(ofType: .user)
    }
    
    func listRowComplications(withInstance: Bool) -> Set<AccountListRowBody.Complication> {
        var complications: Set<AccountListRowBody.Complication> = [.unreadCount, .isActive]
        if withInstance {
            complications.insert(.instance)
        }
        switch preferredListRowComplication {
        case .lastUsed:
            complications.insert(.lastUsed)
        case .responseTime:
            complications.insert(.responseTime)
        }
        return complications
    }
    
    func fetchUnreadCounts() {
        for account in accountsTracker.allAccounts {
            Task {
                do {
                    async let response = fetchVersionNumber(account: account)
                    let unreadCount = try? await account.api.getUnreadCount()
                    let (software, responseTime) = try await response
                    account.updateSoftware(software)

                    self.unreadCountResponses[account.actorId] = .init(
                        unreadCount: unreadCount,
                        responseTime: responseTime
                    )
                } catch {
                    handleError(error)
                }
            }
        }
    }

    func fetchVersionNumber(account: any Account) async throws -> (SiteSoftware, TimeInterval) {
        let startTime = Date.now
        let software = try await account.api.getSoftwareFallback()
        let interval = Date.now.timeIntervalSince(startTime)
        return (software, interval)
    }
}
