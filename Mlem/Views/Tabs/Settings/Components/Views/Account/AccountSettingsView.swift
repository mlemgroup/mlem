//
//  AccountSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 22/11/2023.
//

import Dependencies
import SwiftUI

struct AccountSettingsView: View {
    @Dependency(\.siteInformation) var siteInformation: SiteInformationTracker
    @Dependency(\.accountsTracker) var accountsTracker: SavedAccountTracker
    
    @EnvironmentObject var appState: AppState
    @Environment(\.setAppFlow) private var setFlow

    @State var displayName: String = ""
    @State var showNsfw: Bool = false
    
    @State var showingSignOutConfirmation: Bool = false
    
    @State var accountForDeletion: SavedAccount?
    
    init() {
        if let info = siteInformation.myUserInfo {
            self.displayName = info.localUserView.person.displayName ?? ""
            self.showNsfw = info.localUserView.localUser.showNsfw
        }
    }
    
    var body: some View {
        Form {
            if let info = siteInformation.myUserInfo {
                Section {
                    VStack(spacing: AppConstants.postAndCommentSpacing) {
                        AvatarBannerView(user: .init(from: info.localUserView.person))
                        VStack(spacing: 5) {
                            Text(info.localUserView.person.displayName ?? info.localUserView.person.name)
                                .font(.title)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                            if let account = appState.currentActiveAccount, let hostName = account.hostName {
                                Text("@\(info.localUserView.person.name)@\(hostName)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color(.systemGroupedBackground))
                    .padding(.vertical, -12)
                    .padding(.horizontal, -16)
                }
                
                // See comments under APIListingType for why this is necessary.
                // TODO: 0.17 deprecation remove this logic
                let settingsDisabled = (siteInformation.version ?? .infinity) < .init("0.18.0")
                
                Section {
                    NavigationLink(.settings(.editProfile)) {
                        Label("My Profile", systemImage: "person.fill")
                            .labelStyle(SquircleLabelStyle(color: .indigo))
                    }
                    NavigationLink(.settings(.signInAndSecurity)) {
                        Label("Sign-In & Security", systemImage: "key.fill")
                            .labelStyle(SquircleLabelStyle(color: .blue))
                    }
                    NavigationLink(.settings(.accountGeneral)) {
                        Label("Content & Notifications", systemImage: "list.bullet.rectangle.fill")
                            .labelStyle(SquircleLabelStyle(color: .orange))
                    }
                    NavigationLink(.settings(.accountAdvanced)) {
                        Label("Advanced", systemImage: "gearshape.2.fill")
                            .labelStyle(SquircleLabelStyle(color: .gray))
                    }
                } footer: {
                    if settingsDisabled {
                        // swiftlint:disable:next line_length
                        Text("Account settings are only available on instances running 0.18.0 or above. Your instance is running version \(String(describing: siteInformation.version ?? .zero)).")
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
                    Button("Sign Out", role: .destructive) {
                        showingSignOutConfirmation = true
                    }
                    .frame(maxWidth: .infinity)
                    .confirmationDialog("Really sign out?", isPresented: $showingSignOutConfirmation) {
                        Button("Sign Out", role: .destructive) {
                            Task {
                                if let currentActiveAccount = appState.currentActiveAccount {
                                    accountsTracker.removeAccount(account: currentActiveAccount)
                                    if let first = accountsTracker.savedAccounts.first {
                                        setFlow(.account(first))
                                    } else {
                                        setFlow(.onboarding)
                                    }
                                }
                            }
                        }
                    } message: {
                        Text("Really sign out?")
                    }
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
        .hoistNavigation()
        .sheet(item: $accountForDeletion) { account in
            DeleteAccountView(account: account)
        }
    }
}
