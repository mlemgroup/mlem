//
//  AccountListRowBody.swift
//  Mlem
//
//  Created by Sjmarf on 24/05/2024.
//

import NukeUI
import SwiftUI

struct AccountListRowBody: View {
    @Environment(AppState.self) private var appState
    
    enum Complication: CaseIterable {
        case instance, lastUsed, isActive
    }
    
    let account: any Account
    var complications: Set<Complication> = .withTime
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            CircleCroppedImageView(account, frame: 40, showProgress: false)
                .padding(.leading, -5)
            VStack(alignment: .leading) {
                Text(account.nickname)
                if let captionText {
                    Text(captionText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, -2)
            Spacer()
            if complications.contains(.isActive), appState.firstSession.actorId == account.actorId {
                Image(systemName: Icons.present)
                    .foregroundStyle(.themedPositive)
                    .font(.system(size: 10.0))
            }
        }
        .contentShape(Rectangle())
    }
    
    var timeText: String? {
        switch account.activityState {
        case let .inactive(lastUsed):
            guard let lastUsed else { return nil }
            if abs(lastUsed.timeIntervalSinceNow) < 5 {
                return .init(localized: "Just Now")
            }
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            return formatter.localizedString(for: lastUsed, relativeTo: Date.now)
        case .active:
            return .init(localized: "Now")
        }
    }
    
    var captionText: String? {
        var output: [String] = []
        if complications.contains(.instance) {
            if account is GuestAccount {
                output.append(.init(localized: "Guest"))
            } else {
                output.append("@\(account.api.host)")
            }
        }
        if complications.contains(.lastUsed), let timeText {
            if (account as? GuestAccount)?.isSaved ?? true {
                output.append(timeText)
            } else {
                output.append(.init(localized: "Temporary"))
            }
        }
        return output.joined(separator: " • ")
    }
}

extension Set<AccountListRowBody.Complication> {
    static let withTime: Self = [.instance, .lastUsed, .isActive]
    static let instanceOnly: Self = [.instance, .isActive]
    static let timeOnly: Self = [.lastUsed, .isActive]
}
