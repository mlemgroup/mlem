//
//  Instance and Community List View.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import SwiftUI
import AlertToast

struct AccountsPage: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var accountsTracker: SavedAccountTracker

    @Binding var isShowingInstanceAdditionSheet: Bool

    @State var selection: Int?

    var body: some View {
        VStack {
            if !accountsTracker.savedAccounts.isEmpty {
                List(selection: $appState.currentActiveAccount) {
                    ForEach(accountsTracker.savedAccounts, id: \.self) { savedAccount in
                        HStack(alignment: .center) {
                            Text(savedAccount.username)
                            Spacer()
                            Text(savedAccount.instanceLink.host!)
                                .foregroundColor(.secondary)
                        }
                        .id(savedAccount)
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                    }
                    .onDelete(perform: deleteAccount)
                }
            } else {
                VStack(alignment: .center, spacing: 15) {
                    Text("You have no accounts added")
                }
                .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Accounts")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingInstanceAdditionSheet.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }

    internal func deleteAccount(at offsets: IndexSet) {
        for index in offsets {
            let savedAccountToRemove: SavedAccount = accountsTracker.savedAccounts[index]

            accountsTracker.savedAccounts.remove(at: index)

            // MARK: - Purge the account information from the Keychain

            AppConstants.keychain["\(savedAccountToRemove.id)_accessToken"] = nil
        }
    }
}
