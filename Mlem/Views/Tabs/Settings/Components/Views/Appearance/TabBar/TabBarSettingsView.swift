//
//  TabBarSettingsView.swift
//  Mlem
//
//  Created by Sam Marfleet on 19/07/2023.
//

import Dependencies
import SwiftUI

struct TabBarSettingsView: View {
    @AppStorage("profileTabLabel") var profileTabLabel: ProfileTabLabel = .nickname
    @AppStorage("showTabNames") var showTabNames: Bool = true
    @AppStorage("showUnreadPersonal") var showUnreadPersonal: Bool = true
    @AppStorage("showUnreadModerator") var showUnreadModerator: Bool = true
    @AppStorage("showUnreadMessageReports") var showUnreadMessageReports: Bool = true
    @AppStorage("showUnreadApplications") var showUnreadApplications: Bool = true
    @AppStorage("showUserAvatarOnProfileTab") var showUserAvatar: Bool = true
    @AppStorage("homeButtonExists") var homeButtonExists: Bool = false
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Form {
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.label,
                    settingName: "Tab Labels",
                    isTicked: $showTabNames
                )
            }
            
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.unreadBadge,
                    settingName: "Personal Notifications",
                    isTicked: $showUnreadPersonal
                )
                
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.moderation,
                    settingName: "Post and Comment Reports",
                    isTicked: $showUnreadModerator
                )
                
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.messageReportSetting,
                    settingName: "Message Reports",
                    isTicked: $showUnreadMessageReports
                )
                
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.registrationApplication,
                    settingName: "Registration Applications",
                    isTicked: $showUnreadApplications
                )
            } header: {
                Text("Inbox Unread Badge")
            }
            
            // TODO: options like this will need to be updated to only show when there is an active account
            // present once guest mode is fully implemented
            Section {
                HStack {
                    ForEach(ProfileTabLabel.allCases, id: \.self) { item in
                        VStack(spacing: 10) {
                            let account = appState.currentActiveAccount
                            if let avatar = account?.avatarUrl, item != .anonymous, showUserAvatar {
                                AvatarView(url: avatar, type: .user, avatarSize: 42, iconResolution: .unrestricted)
                            } else {
                                Image(systemName: Icons.user)
                                    .resizable()
                                    .frame(width: 42, height: 42)
                            }
                            Group {
                                switch item {
                                case .nickname:
                                    Text(account?.nickname ?? "Nickname")
                                case .instance:
                                    Text(account?.instanceLink.host() ?? "Instance")
                                case .anonymous:
                                    Text("Profile")
                                }
                            }
                            .font(.footnote)
                            Checkbox(isOn: profileTabLabel == item)
                        }
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            profileTabLabel = item
                        }
                    }
                }
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.showAvatar,
                    settingName: "Avatar",
                    // if `.anonymous` is selected the toggle here should always be false
                    isTicked: profileTabLabel == .anonymous ? .constant(false) : $showUserAvatar
                )
                .disabled(profileTabLabel == .anonymous)
            } header: {
                Text("Profile Icon Appearance")
            } footer: {
                VStack(alignment: .leading, spacing: 3) {
                    Text("You can change your account's local nickname in Account Settings.")
                    FooterLinkView(title: "Account Settings", destination: .settings(.accountLocal))
                }
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Tab Bar")
        .navigationBarColor()
        .animation(.easeIn, value: profileTabLabel)
    }
}
