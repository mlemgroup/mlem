//
//  Instance and Community List View.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import SwiftUI

struct AccountsPage: View
{
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var accountsTracker: SavedAccountTracker

    @State private var isShowingInstanceAdditionSheet: Bool = false

    var body: some View
    {
        NavigationView
        {
            VStack
            {
                if !accountsTracker.savedAccounts.isEmpty
                {
                    List
                    {
                        ForEach(accountsTracker.savedAccounts)
                        { savedAccount in
                            NavigationLink
                            {
                                CommunityView(instanceAddress: savedAccount.instanceLink, account: savedAccount, community: nil)
                            } label: {
                                HStack(alignment: .center)
                                {
                                    Text(savedAccount.username)
                                    Spacer()
                                    Text(savedAccount.instanceLink.host!)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true)
                            {
                                Button
                                {
                                    let indexOfSavedAccountToRemove: Int = accountsTracker.savedAccounts.firstIndex(where: { $0.id == savedAccount.id })!

                                    accountsTracker.savedAccounts.remove(at: indexOfSavedAccountToRemove)

                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }
                }
                else
                {
                    VStack(alignment: .center, spacing: 15)
                    {
                        Text("You have no accounts added")
                    }
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Accounts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar
            {
                ToolbarItem(placement: .navigationBarTrailing)
                {
                    Button
                    {
                        isShowingInstanceAdditionSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingInstanceAdditionSheet)
            {
                AddSavedInstanceView(isShowingSheet: $isShowingInstanceAdditionSheet)
            }
        }
        .onAppear
        {
            print("Saved thing from keychain: \(AppConstants.keychain["test"])")
        }
        .alert(isPresented: $appState.isShowingCriticalError) {
            switch appState.criticalErrorType
            {
                case .shittyInternet:
                    return Alert(
                        title: Text("Lost connection to Lemmy"),
                        message: Text("Your internet is not stable enough to connect to Lemmy.\nTry again later."),
                        dismissButton: .default(Text("Close"), action: {
                        appState.isShowingCriticalError = false
                    })
                    )
            }
        }
    }
}
