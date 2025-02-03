//
//  PersonBanEditorView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 2024-11-15.
//

import Foundation

extension PersonBanEditorView {
    var dateFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        return formatter
    }
    
    func send() async {
        do {
            if shouldBan {
                try await banUser()
            } else {
                try await unbanUser()
            }
            dismiss()
        } catch {
            handleError(error)
        }
    }
    
    private func banUser() async throws {
        if targetInstance {
            try await person.banFromInstance(
                removeContent: removeContent,
                reason: reason,
                expires: isPermanent ? nil : expiryDate
            )
        } else if let community {
            try await person.ban(
                from: community,
                removeContent: removeContent,
                reason: reason,
                expires: isPermanent ? nil : expiryDate
            )
        }
    }
    
    private func unbanUser() async throws {
        if targetInstance {
            try await person.unbanFromInstance(reason: reason)
        } else if let community {
            try await person.unban(from: community, reason: reason)
        }
    }
}
