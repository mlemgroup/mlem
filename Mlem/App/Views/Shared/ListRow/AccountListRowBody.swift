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
    
    let account: any AccountProviding
    var complications: Set<Complication> = .withTime
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            AvatarView(account, showLoadingPlaceholder: false)
                .frame(height: 40)
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
                    .foregroundStyle(.green)
                    .font(.system(size: 10.0))
            }
        }
        .contentShape(Rectangle())
    }
    
    var timeText: String? {
        if account.actorId == appState.firstSession.actorId {
            return "Now"
        }
        if let time = account.lastUsed {
            if abs(time.timeIntervalSinceNow) < 5 {
                return "Just Now"
            }
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            return formatter.localizedString(for: time, relativeTo: Date.now)
        }
        return nil
    }
    
    var captionText: String? {
        var output: [String] = []
        if complications.contains(.instance) {
            if account is GuestAccount {
                output.append("Guest")
            } else {
                output.append("@\(account.api.baseUrl.host ?? "unknown")")
            }
        }
        if complications.contains(.lastUsed), let timeText {
            if (account as? GuestAccount)?.isSaved ?? true {
                output.append(timeText)
            } else {
                output.append("Temporary")
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
