//
//  AccountSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 22/11/2023.
//

import Dependencies
import SwiftUI

struct AccountSettingsView: View {
    @Environment(AppState.self) var appState

    @State var displayName: String = ""
    
    @State var showingSignOutConfirmation: Bool = false
    
    @State var accountForDeletion: (any UserProviding)?
    
    init(appState: AppState) {
        if let myUser = appState.myUser as? any Person3Providing {
            self.displayName = myUser.displayName ?? ""
        }
    }
    
    var body: some View {
        Form {
            if let myUser = appState.myUser {

                // See comments under APIListingType for why this is necessary.
                // TODO: 0.17 deprecation remove this logic
                let settingsDisabled = (appState.lemmyVersion ?? .infinity) < .init("0.18.0")
                
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
                        Text("Account settings are only available on instances running 0.18.0 or above. Your instance is running version \(String(describing: appState.lemmyVersion ?? .zero)).")
                            .foregroundStyle(.red)
                            .textCase(.none)
                    }
                }
                .disabled(settingsDisabled)
                
                Section {
                    NavigationLink(.settings(.accountLocal)) {
                        Label("Local Options", systemImage: "iphone.gen3")
                            .labelStyle(SquircleLabelStyle(color: .blue))
                    }
                } footer: {
                    Text("These options are stored locally in Mlem and not on your Lemmy account.")
                }
                
//                Section {
//                    NavigationLink { EmptyView() } label: {
//                        Label("Blocked Commuities", systemImage: "house.fill").labelStyle(SquircleLabelStyle(color: .gray))
//                    }
//                    NavigationLink { EmptyView() } label: {
//                        Label("Blocked Users", systemImage: "person.fill").labelStyle(SquircleLabelStyle(color: .gray))
//                    }
//                }
                
                Section { signOutButton }
                
                Section { deleteButton }
                
            } else {
                Text("No user info")
            }
        }
        .navigationTitle("Account Settings")
        .fancyTabScrollCompatible()
        .hoistNavigation()
    }
    
    @ViewBuilder
    var signOutButton: some View {
        Button("Sign Out", role: .destructive) {
            showingSignOutConfirmation = true
        }
        .frame(maxWidth: .infinity)
        .confirmationDialog("Really sign out?", isPresented: $showingSignOutConfirmation) {
            Button("Sign Out", role: .destructive) {
//                Task {
//                    if let currentActiveAccount = appState.currentActiveAccount {
//                        accountsTracker.removeAccount(account: currentActiveAccount)
//                        if let first = accountsTracker.savedAccounts.first {
//                            setFlow(.account(first))
//                        } else {
//                            setFlow(.onboarding)
//                        }
//                    }
//                }
            }
        } message: {
            Text("Really sign out?")
        }
    }
    
    @ViewBuilder
    var deleteButton: some View {
        Button("Delete Account", role: .destructive) {
            accountForDeletion = appState.myUser
        }
        .frame(maxWidth: .infinity)
        .sheet(item: Binding(get: { accountForDeletion?.actorId }, set: { _ in accountForDeletion = nil })) { _ in
            // DeleteAccountView(account: account)
        }
    }
}
