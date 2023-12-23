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
    @Environment(\.setAppFlow) var setFlow
    
    @AppStorage("accountSort") var accountSort: AccountSortMode = .name
    @AppStorage("groupAccountSort") var groupAccountSort: Bool = false
    @EnvironmentObject var appState: AppState
    
    @ObservedObject var accountsTracker: SavedAccountTracker
    
    struct AccountGroup {
        let header: String
        let accounts: [SavedAccount]
    }
    
    init() {
        // We have to create an ObservedObject here so that changes to the accounts list create view updates
        @Dependency(\.accountsTracker) var accountsTracker: SavedAccountTracker
        self._accountsTracker = ObservedObject(wrappedValue: accountsTracker)
    }
    
    var body: some View {
        if accountsTracker.savedAccounts.count > 2 && groupAccountSort {
            ForEach(Array(accountGroups.enumerated()), id: \.offset) { offset, group in
                Section {
                    ForEach(group.accounts, id: \.self) { account in
                        AccountButtonView(
                            account: account,
                            caption: accountSort != .instance || group.header == "Other" ? .instanceAndTime : .timeOnly
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
        } else {
            Section(header: topHeader()) {
                ForEach(accounts, id: \.self) { account in
                    AccountButtonView(account: account)
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
            if accountsTracker.savedAccounts.count > 2 {
                Spacer()
                Menu {
                    Picker("Sort", selection: $accountSort) {
                        ForEach(AccountSortMode.allCases, id: \.self) { sortMode in
                            Label(sortMode.label, systemImage: sortMode.systemImage).tag(sortMode)
                        }
                    }
                    if accountsTracker.savedAccounts.count > 3 {
                        Divider()
                        Toggle(isOn: $groupAccountSort) {
                            Label("Grouped", systemImage: "square.stack.3d.up.fill")
                        }
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
}
