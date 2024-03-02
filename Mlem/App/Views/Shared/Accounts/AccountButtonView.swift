//
//  AccountButtonView.swift
//  Mlem
//
//  Created by Sjmarf on 22/12/2023.
//

import Dependencies
import NukeUI
import SwiftUI

struct AccountButtonView: View {
    @Dependency(\.accountsTracker) var accountsTracker: AccountsTracker
    @Environment(\.dismiss) var dismiss
    
    @Environment(AppState.self) var appState
    
    @State var showingSignOutConfirmation: Bool = false
    @Binding var isSwitching: Bool
    
    enum CaptionState {
        case instanceOnly, timeOnly, instanceAndTime
    }
    
    let account: UserStub
    let caption: CaptionState
    
    init(account: UserStub, caption: CaptionState = .instanceAndTime, isSwitching: Binding<Bool>) {
        self.account = account
        self.caption = caption
        self._isSwitching = isSwitching
    }
    
    var timeText: String? {
        if account.actorId == appState.actorId {
            return "Now"
        }
        if let time = account.lastLoggedIn {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            return formatter.localizedString(for: time, relativeTo: Date.now)
        }
        return nil
    }
    
    var captionText: String? {
        let host = account.api.baseUrl.host
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
            if appState.actorId != account.actorId {
                // TODO: this crap
                // appState.api = account.api
//                print("DEBUG changing to account with token: \(account.accessToken)")
//                print("DEBUG new account instance token: \(account.instance.api.token)")
                appState.changeUser(to: account)
                dismiss()
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
                        DefaultAvatarView(avatarType: .person)
                    }
                }
                .frame(width: 40, height: 40)
                .padding(.leading, -5)
                VStack(alignment: .leading) {
                    Text(account.nickname ?? account.name)
                    if let captionText {
                        Text(captionText)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, -2)
                Spacer()
                if appState.actorId == account.actorId {
                    Image(systemName: Icons.present)
                        .foregroundStyle(.green)
                        .font(.system(size: 10.0))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            "\(account.fullName ?? "unknown"))\(appState.actorId == account.actorId ? ", active" : "")"
        )
        .swipeActions {
            Button("Sign Out") {
                showingSignOutConfirmation = true
            }
            .tint(.red)
        }
        .confirmationDialog("Really sign out of \(account.nickname ?? account.name)?", isPresented: $showingSignOutConfirmation) {
            Button("Sign Out", role: .destructive) {
                Task {
                    print("TODO: SIGN OUT")
//                    if let currentAccount = appState.apiSource {
//                        print("DEBUG YES")
//                        accountsTracker.removeAccount(account: account)
//                        if currentAccount.actorId == account.actorId {
//                            if let first = accountsTracker.savedAccounts.first {
//                                appState.apiSource = first
//                            } else {
//                                appState.isOnboarding = true
//                            }
//                            dismiss()
//                        }
//                    } else {
//                        print("DEBUG NO")
//                    }
                }
            }
        } message: {
            Text("Really sign out?")
        }
    }
}
