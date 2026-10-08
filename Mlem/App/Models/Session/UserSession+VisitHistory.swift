//
//  UserSession+VisitHistory.swift
//  Mlem
//
//  Created by Sjmarf on 2026-10-04.
//

extension UserSession {
    func saveVisitHistory() async throws {
        if let visitHistory {
            try await PersistenceRepository.liveValue.saveVisitHistory(visitHistory, for: account)
        }
    }
    
    @MainActor
    func setVisitHistoryEnabled(_ newValue: Bool) async throws {
        guard newValue != account.visitHistoryEnabled else { return }
        account.visitHistoryEnabled = newValue
        if newValue {
            visitHistory = .init()
        } else {
            visitHistory = nil
            try await PersistenceRepository.liveValue.saveVisitHistory(.init(), for: account)
        }
        AccountsTracker.main.saveAccounts(ofType: .user)
    }
}
