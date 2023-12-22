//
//  AccountButtonView.swift
//  Mlem
//
//  Created by Sjmarf on 22/12/2023.
//

import SwiftUI

struct AccountButtonView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.setAppFlow) private var setFlow
    
    enum CaptionState {
        case instanceOnly, timeOnly, instanceAndTime
    }
    
    let account: SavedAccount
    let caption: CaptionState
    
    init(account: SavedAccount, caption: CaptionState = .instanceAndTime) {
        self.account = account
        self.caption = caption
    }
    
    var timeText: String? {
        if account == appState.currentActiveAccount {
            return "Now"
        }
        if let time = account.lastUsed {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            return formatter.localizedString(for: time, relativeTo: Date.now)
        }
        return nil
    }
    
    var captionText: String? {
        let host = account.instanceLink.host()
        var caption = caption
        let timeText = timeText
        if timeText == nil {
            caption = .instanceOnly
        }
        switch caption {
        case .instanceOnly:
            return host ?? "unknown"
        case .timeOnly:
            return timeText ?? ""
        case .instanceAndTime:
            return "@\(host ?? "unknown") ∙ \(timeText ?? "")"
        }
    }
    
    var body: some View {
        Button {
            if appState.currentActiveAccount != account {
                setFlow(using: account)
            }
        } label: {
            HStack(alignment: .center, spacing: 10) {
                AvatarView(url: account.avatarUrl, type: .user, avatarSize: 40, iconResolution: .unrestricted)
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
                if appState.currentActiveAccount == account {
                    Text("Active")
                        .foregroundStyle(.secondary)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                        .fontWeight(.semibold)
                        .imageScale(.small)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            "\(account.nickname)@\(account.instanceLink.host() ?? "unknown")\(appState.currentActiveAccount == account ? ", active" : "")"
        )
    }
    
    private func setFlow(using account: SavedAccount?) {
        if let account {
            setFlow(.account(account))
            return
        }
        
        setFlow(.onboarding)
    }
}
