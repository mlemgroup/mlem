//
//  ClearRecentSearchesButton.swift
//  Mlem
//
//  Created by Sjmarf on 2026-10-21.
//

import SwiftUI

struct ClearRecentSearchesButton: View {
    @Environment(AppState.self) var appState
        
    @State var showingConfirmation: Bool = false
        
    var body: some View {
        Button("Clear") {
            showingConfirmation = true
        }
        .confirmationDialog(
            "Clear search history?",
            isPresented: $showingConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear", role: .destructive) {
                if let session = appState.firstSession as? UserSession, let visitHistory = session.visitHistory {
                    visitHistory.clear()
                    Task {
                        do {
                            try await session.saveVisitHistory()
                        } catch {
                            handleError(error)
                        }
                    }
                }
            }
            Button("Turn Off Search History", role: .destructive) {
                if let session = appState.firstSession as? UserSession {
                    Task { @MainActor in
                        do {
                            try await session.setVisitHistoryEnabled(false)
                        } catch {
                            handleError(error)
                        }
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You can also turn off search history completely for this account.")
        }
    }
}
