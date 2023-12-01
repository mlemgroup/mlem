//
//  AccountSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 22/11/2023.
//

import SwiftUI
import Dependencies

struct AccountSettingsView: View {
    @Dependency(\.siteInformation) var siteInformation: SiteInformationTracker
    
    @EnvironmentObject var appState: AppState

    @State var displayName: String = ""
    @State var showNsfw: Bool = false
    
    @State var accountForDeletion: SavedAccount?
    
    init() {
        if let info = siteInformation.myUserInfo {
            displayName = info.localUserView.person.displayName ?? ""
            showNsfw = info.localUserView.localUser.showNsfw
        }
    }
    
    var body: some View {
        
        Form {
            if let info = siteInformation.myUserInfo {
                Section {
                    VStack {
                        AvatarView(url: info.localUserView.person.avatarUrl, type: .user, avatarSize: 96, iconResolution: .unrestricted)
                        Text(info.localUserView.person.displayName ?? info.localUserView.person.name)
                            .font(.largeTitle)
                            .padding(.top, 3)
                        if let account = appState.currentActiveAccount, let hostName = account.hostName {
                            Text("@\(info.localUserView.person.name)@\(hostName)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color(.systemGroupedBackground))
                    .padding(.vertical, -12)
                }
                
                // See comments under APIListingType for why this is necessary.
                // TODO: 0.17 deprecation remove this logic
                let settingsDisabled = (siteInformation.version ?? .infinity) < .init("0.18.0")
                
                Section {
                    NavigationLink(.settings(.editProfile)) {
                        Label("My Profile", systemImage: "person.fill").labelStyle(SquircleLabelStyle(color: .indigo))
                    }
                    NavigationLink(.settings(.signInAndSecurity)) {
                        Label("Sign-In & Security", systemImage: "key.fill").labelStyle(SquircleLabelStyle(color: .blue))
                    }
                    NavigationLink(.settings(.accountContent)) {
                        Label("Content", systemImage: "list.bullet.rectangle.fill").labelStyle(SquircleLabelStyle(color: .orange))
                    }
                    NavigationLink(.settings(.accountNotifications)) {
                        Label("Notifications", systemImage: "bell.fill").labelStyle(SquircleLabelStyle(color: .red))
                    }
                } footer: {
                    if settingsDisabled {
                        // swiftlint:disable:next line_length
                        Text("We don't support editing of account settings on instances running versions older than 0.18.0 due to API differences on those versions. Your instance is running version \(String(describing: siteInformation.version ?? .zero)). Sorry!")
                            .foregroundStyle(.red)
                            .textCase(.none)
                    }
                }
                .disabled(settingsDisabled)
                
//                Section {
//                    NavigationLink { EmptyView() } label: {
//                        Label("Blocked Commuities", systemImage: "house.fill").labelStyle(SquircleLabelStyle(color: .gray))
//                    }
//                    NavigationLink { EmptyView() } label: {
//                        Label("Blocked Users", systemImage: "person.fill").labelStyle(SquircleLabelStyle(color: .gray))
//                    }
//                }
                
                Section {
                    Button("Sign Out", role: .destructive) { }
                        .frame(maxWidth: .infinity)
                }
                
                Section {
                    Button("Delete Account", role: .destructive) {
                        accountForDeletion = appState.currentActiveAccount
                    }
                        .frame(maxWidth: .infinity)
                }
                
            } else {
                Text("No user info")
            }
        }
        .navigationTitle("Account Settings")
        .fancyTabScrollCompatible()
        .sheet(item: $accountForDeletion) { account in
            DeleteAccountView(account: account)
        }
    }
}
