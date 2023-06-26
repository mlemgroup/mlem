//
//  Instance and Community List View.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import SwiftUI
import AlertToast

struct AccountsPage: View
{
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var accountsTracker: SavedAccountTracker

    @State private var isShowingInstanceAdditionSheet: Bool = false

    @State var navigationPath = NavigationPath()



    var body: some View
    {
        NavigationStack(path: $navigationPath)
        {
            VStack
            {
                if !accountsTracker.savedAccounts.isEmpty
                {
                    List
                    {
                        ForEach(accountsTracker.savedAccounts)
                        { savedAccount in
                            NavigationLink(value: savedAccount)
                            {
                                HStack(alignment: .center)
                                {
                                    Text(savedAccount.username)
                                    Spacer()
                                    Text(savedAccount.instanceLink.host!)
                                        .foregroundColor(.secondary)
                                }
                                .minimumScaleFactor(0.01)
                                .lineLimit(1)
                            }
                        }
                        .onDelete(perform: deleteAccount)
                    }
                    .toolbar
                    {
                        ToolbarItem(placement: .navigationBarLeading)
                        {
                            EditButton()
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
            .handleLemmyViews(navigationPath: $navigationPath)
            .onAppear
            {
                // this means that we got to this page not by going back from any account
                // (since if we had gone into any account it will only get rest on the next line so currentActiveAccount should still be set to something)
                let shouldDisplayFirstUser = appState.currentActiveAccount == nil

                // now we reset the account
                appState.currentActiveAccount = nil
                
                if shouldDisplayFirstUser, let firstAccount = accountsTracker.savedAccounts.first {
                    // I know this looks super odd but it give SwiftUI just a bit of time to get ahold of itself
                    Task {
                        await MainActor.run {
                            navigationPath.append(firstAccount)
                        }
                    }
                }
            }
            .navigationDestination(for: SavedAccount.self) { account in
                CommunityListView(account: account)
                    .onAppear {
                        appState.currentActiveAccount = account
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
        .toast(isPresenting: $appState.isShowingToast) {
            appState.toast ?? AlertToast(type: .regular, title: "Missing toast info")
        }
        .alert(appState.alertTitle, isPresented: $appState.isShowingAlert)
        {
            Button(role: .cancel)
            {
                appState.isShowingAlert.toggle()
            } label: {
                Text("Close")
            }

        } message: {
            Text(appState.alertMessage)
        }
        .onAppear
        {
            print("Saved thing from keychain: \(String(describing: AppConstants.keychain["test"]))")
        }
        .environment(\.navigationPath, $navigationPath)
        .handleLemmyLinkResolution(navigationPath: $navigationPath)
    }

    internal func deleteAccount(at offsets: IndexSet)
    {
        for index in offsets
        {
            let savedAccountToRemove: SavedAccount = accountsTracker.savedAccounts[index]

            accountsTracker.savedAccounts.remove(at: index)

            // MARK: - Purge the account information from the Keychain

            AppConstants.keychain["\(savedAccountToRemove.id)_accessToken"] = nil
        }
    }
}
