//
//  AccountLocalSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-02.
//

import SwiftUI

struct AccountLocalSettingsView: View {
    @Environment(AppState.self) var appState
    
    @State var isShowingFavoriteDeletionWarning: Bool = false
    @State var isShowingClearVisitHistoryWarning: Bool = false
    @State var isShowingDisableVisitHistoryWarning: Bool = false

    var body: some View {
        Form {
            AccountNicknameFieldView()
            if let userSession = AppState.main.firstSession as? UserSession {
                communityFavoritesSection(userSession)
                Section {
                    visitHistoryToggle(userSession)
                    if let visitHistory = userSession.visitHistory {
                        clearVisitHistoryButton(userSession, visitHistory: visitHistory)
                    }
                }
            }
        }
        .navigationTitle("Local Options")
    }
    
    @ViewBuilder
    func communityFavoritesSection(_ session: UserSession) -> some View {
        Section {
            Button("Delete Community Favorites", icon: .general.delete, role: .destructive) {
                isShowingFavoriteDeletionWarning = true
            }
            .disabled(session.account.favorites.isEmpty)
            .tint(.themedWarning)
            .confirmationDialog(
                "Delete Community Favorites",
                isPresented: $isShowingFavoriteDeletionWarning
            ) {
                Button("Delete", role: .destructive) {
                    for community in session.subscriptions.favorites {
                        community.updateFavorite(false)
                    }
                }
            } message: {
                Text("Are you sure you want to delete all community favorites for this account? This cannot be undone.")
            }
        } footer: {
            if session.account.favorites.isEmpty {
                Text("This account has no favorite communities.")
            } else {
                Text("This account has \(session.account.favorites.count) favorite communities.")
            }
        }
    }
    
    @ViewBuilder
    func visitHistoryToggle(_ session: UserSession) -> some View {
        Toggle(
            "Remember Search History",
            isOn: .init(
                get: { session.account.visitHistoryEnabled },
                set: { newValue in
                    if newValue || (session.visitHistory?.isEmpty ?? true) {
                        Task { @MainActor in
                            try await session.setVisitHistoryEnabled(newValue)
                        }
                    } else {
                        isShowingDisableVisitHistoryWarning = true
                    }
                }
            )
        )
        .confirmationDialog(
            "Turn off search history?",
            isPresented: $isShowingDisableVisitHistoryWarning,
            titleVisibility: .visible
        ) {
            Button("Turn Off", role: .destructive) {
                Task { @MainActor in
                    do {
                        try await session.setVisitHistoryEnabled(false)
                    } catch {
                        handleError(error)
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will clear your recent searches, which cannot be undone.")
        }
    }
    
    @ViewBuilder
    func clearVisitHistoryButton(_ session: UserSession, visitHistory: VisitHistory) -> some View {
        if let visitHistory = session.visitHistory {
            Button("Clear Search History", icon: .general.delete, role: .destructive) {
                isShowingClearVisitHistoryWarning = true
            }
            .tint(.themedWarning)
            .confirmationDialog(
                "Clear search history?",
                isPresented: $isShowingClearVisitHistoryWarning,
                titleVisibility: .visible
            ) {
                Button("Clear", role: .destructive) {
                    visitHistory.clear()
                    Task {
                        do {
                            try await session.saveVisitHistory()
                        } catch {
                            handleError(error)
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
}
