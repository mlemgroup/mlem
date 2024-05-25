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
        case instance, lastUsed
    }
    
    let account: any Account
    var complications: Set<Complication> = .withTime
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // Using AvatarView or CachedImage here causes the quick switcher sheet to be locked to `.large` on iOS 17. To avoid this, we're using LazyImage directly instead - Sjmarf
            LazyImage(url: account.avatar) { state in
                if let imageContainer = state.imageContainer {
                    Image(uiImage: imageContainer.image)
                        .resizable()
                        .clipShape(Circle())
                } else {
                    DefaultAvatarView(avatarType: .person)
                }
            }
            .frame(width: 40, height: 40)
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
            if appState.firstSession.actorId == account.actorId {
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
    static let withTime: Self = [.instance, .lastUsed]
    static let instanceOnly: Self = [.instance]
    static let timeOnly: Self = [.lastUsed]
}
