//
//  AccountLocalSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-02.
//

import SwiftUI

struct AccountLocalSettingsView: View {
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    
    @State var isShowingFavoriteDeletionWarning: Bool = false
    
    var body: some View {
        Form {
            AccountNicknameFieldView()
            if let userSession = AppState.main.firstSession as? UserSession {
                Section {
                    Button("Delete Community Favorites", systemImage: Icons.delete, role: .destructive) {
                        isShowingFavoriteDeletionWarning = true
                    }
                    .disabled(userSession.account.favorites.isEmpty)
                    .tint(palette.warning)
                    .confirmationDialog(
                        "Delete Community Favorites",
                        isPresented: $isShowingFavoriteDeletionWarning
                    ) {
                        Button("Delete", role: .destructive) {
                            for community in userSession.subscriptions.favorites {
                                community.updateFavorite(false)
                            }
                        }
                    } message: {
                        Text("Are you sure you want to delete all community favorites for this account? This cannot be undone.")
                    }
                } footer: {
                    if userSession.account.favorites.isEmpty {
                        Text("You have not favorited any communities on this account.")
                    } else {
                        Text("You have favorited \(userSession.account.favorites.count) communities on this account.")
                    }
                }
            }
        }
    }
}
