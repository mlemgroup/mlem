//
//  LocalAccountSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 21/01/2024.
//

import Dependencies
import SwiftUI

struct LocalAccountSettingsView: View {
    @AppStorage("profileTabLabel") var profileTabLabel: ProfileTabLabel = .nickname
    @AppStorage("showSettingsIcons") var showSettingsIcons: Bool = false
    
    @Environment(AppState.self) var appState
    
    @State var nickname: String = ""
    @State private var isShowingFavoritesDeletionConfirmation: Bool = false
    
    var body: some View {
        Form {
            Section {
                TextField("Nickname", text: $nickname, prompt: Text(appState.myUser?.name ?? "Nickname"))
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
//                    .onSubmit {
//                        guard var existingAccount = appState.currentActiveAccount else {
//                            return
//                        }
//                        
//                        let acceptedNickname = nickname.trimmed.isEmpty ? nil : nickname
//                        existingAccount.storedNickname = nil
//                        
//                        let newAccount = SavedAccount(
//                            from: existingAccount,
//                            storedNickname: acceptedNickname,
//                            avatarUrl: existingAccount.avatarUrl
//                        )
//                        appState.setActiveAccount(newAccount)
//                    }
//                    .onAppear {
//                        nickname = appState.currentActiveAccount?.storedNickname ?? ""
//                    }
//                    .onChange(of: appState.currentActiveAccount?.nickname) { nickname in
//                        self.nickname = nickname ?? ""
//                    }
            } header: {
                Text("Nickname")
            } footer: {
                if profileTabLabel == .nickname {
                    Text("The name shown in the account switcher and tab bar.")
                }
                Text("The name shown in the account switcher.")
            }
            
            Section {
                Button(role: .destructive) {
                    isShowingFavoritesDeletionConfirmation.toggle()
                } label: {
                    Label {
                        Text("Delete Community Favorites")
                    } icon: {
                        if showSettingsIcons {
                            Image(systemName: Icons.delete)
                        }
                    }
                    .foregroundColor(.red)
                    // .opacity(favoriteCommunitiesTracker.favoritesForCurrentAccount.isEmpty ? 0.6 : 1)
                }
                // .disabled(favoriteCommunitiesTracker.favoritesForCurrentAccount.isEmpty)
                .confirmationDialog(
                    "Delete community favorites for this account?",
                    isPresented: $isShowingFavoritesDeletionConfirmation,
                    titleVisibility: .visible
                ) {
                    Button(role: .destructive) {
                        // favoriteCommunitiesTracker.clearCurrentFavourites()
                    } label: {
                        Text("Delete all favorites")
                    }
                    
                    Button(role: .cancel) {
                        isShowingFavoritesDeletionConfirmation.toggle()
                    } label: {
                        Text("Cancel")
                    }

                } message: {
                    Text("You cannot undo this action.")
                }
            } footer: {
                // let favorites = favoriteCommunitiesTracker.favoritesForCurrentAccount
//                if favorites.isEmpty {
//                    Text("You haven't favorited any communities on this account.")
//                } else {
//                    Text("You've favorited ^[\(favorites.count) community](inflect:true) on this account.")
//                }
            }
        }
        .navigationTitle("Local Options")
        .fancyTabScrollCompatible()
        .hoistNavigation()
    }
}
