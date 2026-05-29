//
//  SettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 07/05/2024.
//

import MlemMiddleware
import SwiftUI
import Theming

struct SettingsView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    @Setting(\.appearance_palette) var colorPalette
    
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
                    icon: .settings.general,
                    destination: .settings(.general)
                )
                .gradientTint(.themedNeutralAccent)
                NavigationLink(
                    "Privacy",
                    icon: .settings.privacy,
                    destination: .settings(.privacy)
                )
                .gradientTint(.themedColorfulAccent(2))
                NavigationLink(
                    "Safety & Filtering",
                    icon: .settings.safety,
                    destination: .settings(.safety)
                )
                .gradientTint(.themedColorfulAccent(3))
                NavigationLink(
                    "Accessibility",
                    icon: .settings.accessibility,
                    destination: .settings(.accessibility)
                )
                .gradientTint(.themedColorfulAccent(2))
                NavigationLink(
                    "Media & Links",
                    icon: .general.image,
                    destination: .settings(.links)
                )
                .gradientTint(.themedColorfulAccent(4))
                NavigationLink(
                    "Sorting",
                    icon: .settings.sorting,
                    destination: .settings(.sorting)
                )
                .gradientTint(.themedColorfulAccent(5))
                if AccountsTracker.main.highestLevelAccountType >= .moderator {
                    NavigationLink(
                        "Moderation",
                        icon: .lemmy.moderation,
                        destination: .settings(.moderation)
                    )
                    .gradientTint(.themedModeration)
                    .symbolVariant(.fill)
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
                NavigationLink("Posts", icon: .lemmy.post, destination: .settings(.post))
                    .gradientTint(.themedPostAccent)
                NavigationLink("Comments", icon: .lemmy.comment, destination: .settings(.comment))
                    .gradientTint(.themedCommentAccent)
                NavigationLink("Inbox", icon: .lemmy.inbox, destination: .settings(.inbox))
                    .gradientTint(.themedInbox)
                NavigationLink("Communities", icon: .lemmy.community, destination: .settings(.community))
                    .gradientTint(.themedCommunityAccent)
                NavigationLink("Users", icon: .lemmy.person, destination: .settings(.person))
                    .gradientTint(.themedPersonAccent)
                NavigationLink("Instances", icon: .lemmy.instance, destination: .settings(.instance))
                    .gradientTint(.themedInstanceAccent)
                NavigationLink("Tab Bar", icon: .settings.tabBar, destination: .settings(.tabBar))
                    .gradientTint(.themedColorfulAccent(5))
            }
            
            Section {
                NavigationLink("About Mlem", icon: .general.info, destination: .settings(.about))
                    .gradientTint(.themedColorfulAccent(2))
                NavigationLink("Advanced", icon: .settings.advanced, destination: .settings(.advanced))
                    .gradientTint(.themedNeutralAccent)
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
                    fallback: .personAvatar,
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
