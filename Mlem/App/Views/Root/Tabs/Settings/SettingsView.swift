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
                .tint(ThemedColor.themedNeutralAccent.gradient)
                NavigationLink(
                    "Privacy",
                    icon: .settings.privacy,
                    destination: .settings(.privacy)
                )
                .tint(ThemedColor.themedColorfulAccent(2).gradient)
                NavigationLink(
                    "Safety & Filtering",
                    icon: .settings.safety,
                    destination: .settings(.safety)
                )
                .tint(ThemedColor.themedColorfulAccent(3).gradient)
                NavigationLink(
                    "Accessibility",
                    icon: .settings.accessibility,
                    destination: .settings(.accessibility)
                )
                .tint(ThemedColor.themedColorfulAccent(2).gradient)
                NavigationLink(
                    "Media & Links",
                    icon: .general.image,
                    destination: .settings(.links)
                )
                .tint(ThemedColor.themedColorfulAccent(4).gradient)
                NavigationLink(
                    "Sorting",
                    icon: .settings.sorting,
                    destination: .settings(.sorting)
                )
                .tint(ThemedColor.themedColorfulAccent(5).gradient)
                if AccountsTracker.main.highestLevelAccountType >= .moderator {
                    NavigationLink(
                        "Moderation",
                        icon: .lemmy.moderation,
                        destination: .settings(.moderation)
                    )
                    .tint(ThemedColor.themedModeration.gradient)
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
                    .tint(ThemedColor.themedPostAccent.gradient)
                NavigationLink("Comments", icon: .lemmy.comment, destination: .settings(.comment))
                    .tint(ThemedColor.themedCommentAccent.gradient)
                NavigationLink("Inbox", icon: .lemmy.inbox, destination: .settings(.inbox))
                    .tint(ThemedColor.themedInbox.gradient)
                NavigationLink("Subscription List", icon: .lemmy.subscriptionList, destination: .settings(.subscriptionList))
                    .tint(ThemedColor.themedCommunityAccent.gradient)
                NavigationLink("Tab Bar", icon: .settings.tabBar, destination: .settings(.tabBar))
                    .tint(ThemedColor.themedColorfulAccent(5).gradient)
            }
            
            Section {
                NavigationLink("About Mlem", icon: .general.info, destination: .settings(.about))
                    .tint(ThemedColor.themedColorfulAccent(2).gradient)
                NavigationLink("Advanced", icon: .settings.advanced, destination: .settings(.advanced))
                    .tint(ThemedColor.themedNeutralAccent.gradient)
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
