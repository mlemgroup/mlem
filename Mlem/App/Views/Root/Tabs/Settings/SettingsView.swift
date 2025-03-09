//
//  SettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 07/05/2024.
//

import MlemMiddleware
import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    @Setting(\.colorPalette) var colorPalette
    
    @State var currentIcon: String? = UIApplication.shared.alternateIconName

    var accounts: [UserAccount] { AccountsTracker.main.userAccounts }
    
    var body: some View {
        Form {
            Section {
                accountSettingsLink
                accountListLink
            }
            Section {
                NavigationLink(
                    "General",
                    systemImage: "gear",
                    destination: .settings(.general)
                )
                .tint(.themedNeutralAccent)
                NavigationLink(
                    "Privacy",
                    systemImage: Icons.privacy,
                    destination: .settings(.privacy)
                )
                .tint(.themedColorfulAccent(2))
                NavigationLink(
                    "Safety & Filtering",
                    systemImage: "shield.lefthalf.filled",
                    destination: .settings(.safety)
                )
                .tint(.themedColorfulAccent(3))
                NavigationLink(
                    "Accessibility",
                    systemImage: "hand.point.up.braille.fill",
                    destination: .settings(.accessibility)
                )
                .tint(.themedColorfulAccent(2))
                NavigationLink(
                    "Media & Links",
                    systemImage: "photo.fill",
                    destination: .settings(.links)
                )
                .tint(.themedColorfulAccent(4))
                NavigationLink(
                    "Sorting",
                    systemImage: "arrow.up.and.down.text.horizontal",
                    destination: .settings(.sorting)
                )
                .tint(.themedColorfulAccent(5))
                if AccountsTracker.main.highestLevelAccountType >= .moderator {
                    NavigationLink(
                        "Moderation",
                        systemImage: Icons.moderationFill,
                        destination: .settings(.moderation)
                    )
                    .tint(.themedModeration)
                }
            }
            
            Section {
                appIconSettingsLink
                NavigationLink(.settings(.theme)) {
                    ThemeLabel(title: "Theme", palette: colorPalette)
                }
                .labelStyle(.automatic)
            }
            
            Section {
                NavigationLink("Posts", systemImage: "doc.plaintext.fill", destination: .settings(.post))
                    .tint(.themedPostAccent)
                NavigationLink("Comments", systemImage: "bubble.fill", destination: .settings(.comment))
                    .tint(.themedCommentAccent)
                NavigationLink("Inbox", systemImage: Icons.inboxFill, destination: .settings(.inbox))
                    .tint(.themedInbox)
                NavigationLink("Subscription List", systemImage: "list.bullet", destination: .settings(.subscriptionList))
                    .tint(.themedCommunityAccent)
                NavigationLink("Tab Bar", systemImage: "platter.filled.bottom.iphone", destination: .settings(.tabBar))
                    .tint(.themedColorfulAccent(5))
            }
            
            Section {
                NavigationLink("About Mlem", systemImage: "info.circle.fill", destination: .settings(.about))
                    .tint(.themedColorfulAccent(2))
                NavigationLink("Advanced", systemImage: "gearshape.2.fill", destination: .settings(.advanced))
                    .tint(.themedNeutralAccent)
            }
        }
        .labelStyle(.squircle)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    var accountSettingsLink: some View {
        NavigationLink(.settings(.account)) {
            let account = appState.firstSession
            HStack(spacing: 23) {
                CircleCroppedImageView(account.account, frame: 54)
                    .padding(.vertical, -6)
                    .padding(.leading, 3)
                VStack(alignment: .leading, spacing: 3) {
                    Text(account is UserSession ? account.account.nickname : "Guest")
                        .font(.title2)
                    Text(accountSettingsLinkSubtitle)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var appIconSettingsLink: some View {
        NavigationLink(.settings(.icon)) {
            Label {
                Text("App Icon")
            } icon: {
                let icon = AlternateIcon(id: currentIcon, name: String(""))
                AlternateIconLabel(icon: icon, selected: true).getImage()
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.main.settingsIconSize, height: Constants.main.settingsIconSize)
                    .cornerRadius(Constants.main.smallItemCornerRadius)
            }
        }
        .onChange(of: UIApplication.shared.alternateIconName) {
            currentIcon = UIApplication.shared.alternateIconName
        }
    }
    
    var accountSettingsLinkSubtitle: String { "@\(appState.firstSession.account.host)" }
    
    @ViewBuilder
    var accountListLink: some View {
        NavigationLink(.settings(.accounts)) {
            HStack(spacing: 10) {
                AvatarStackView(
                    urls: accounts.prefix(4).map(\.avatar),
                    fallback: .person,
                    height: 28,
                    spacing: accounts.count <= 3 ? 18 : 14,
                    outlineWidth: 0.7,
                    showPlusIcon: accounts.count == 1
                )
                .frame(height: 28)
                .frame(minWidth: 80)
                .padding(.leading, -10)
                Text("Accounts")
                Spacer()
                Text(String(accounts.count))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
