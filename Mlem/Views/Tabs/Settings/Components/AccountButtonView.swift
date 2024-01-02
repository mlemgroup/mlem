//
//  AccountButtonView.swift
//  Mlem
//
//  Created by Sjmarf on 22/12/2023.
//

import SwiftUI
import Dependencies
import NukeUI

struct AccountButtonView: View {
    @EnvironmentObject var appState: AppState
    @Dependency(\.accountsTracker) var accountsTracker: SavedAccountTracker
    @Environment(\.setAppFlow) private var setFlow
    @Environment(\.dismiss) var dismiss
    
    @State var showingSignOutConfirmation: Bool = false
    
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
            return "@\(host ?? "unknown")"
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
                // Using AvatarView or CachedImage here causes the quick switcher sheet to be locked to `.large` on iOS 17. To avoid this, we're using LazyImage directly instead - Sjmarf
                LazyImage(url: account.avatarUrl) { state in
                    if let imageContainer = state.imageContainer {
                        Image(uiImage: imageContainer.image)
                            .resizable()
                            .clipShape(Circle())
                    } else {
                        DefaultAvatarView(avatarType: .user)
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
                if appState.currentActiveAccount == account {
                    Image(systemName: Icons.present)
                        .foregroundStyle(.green)
                        .font(.system(size: 10.0))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            "\(account.nickname)@\(account.instanceLink.host() ?? "unknown")\(appState.currentActiveAccount == account ? ", active" : "")"
        )
        .swipeActions {
            Button("Sign Out") {
                showingSignOutConfirmation = true
            }
            .tint(.red)
        }
        .confirmationDialog("Really sign out of \(account.nickname)?", isPresented: $showingSignOutConfirmation) {
            Button("Sign Out", role: .destructive) {
                Task {
                    if let currentActiveAccount = appState.currentActiveAccount {
                        accountsTracker.removeAccount(account: account)
                        if currentActiveAccount == account {
                            if let first = accountsTracker.savedAccounts.first {
                                setFlow(.account(first))
                            } else {
                                setFlow(.onboarding)
                            }
                        }
                    }
                }
            }
        } message: {
            Text("Really sign out?")
        }
    }
    
    private func setFlow(using account: SavedAccount?) {
        if let account {
            dismiss()
            setFlow(.account(account))
            return
        }
        
        setFlow(.onboarding)
    }
}
