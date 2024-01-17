//
//  GeneralSettingsView.swift
//  Mlem
//
//  Created by David Bureš on 19.05.2023.
//

import Dependencies
import SwiftUI

struct GeneralSettingsView: View {
    @Dependency(\.favoriteCommunitiesTracker) var favoriteCommunitiesTracker
    @Dependency(\.siteInformation) var siteInformation: SiteInformationTracker
    
    @AppStorage("confirmImageUploads") var confirmImageUploads: Bool = true
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
    @AppStorage("appLock") var appLock: AppLock = .disabled
    
    @AppStorage("defaultFeed") var defaultFeed: FeedType = .subscribed
    
    @AppStorage("hapticLevel") var hapticLevel: HapticPriority = .low
    @AppStorage("upvoteOnSave") var upvoteOnSave: Bool = false
    
    @AppStorage("showSettingsIcons") var showSettingsIcons: Bool = false
    @AppStorage("openLinksInBrowser") var openLinksInBrowser: Bool = false

    @EnvironmentObject var appState: AppState

    @State private var isShowingFavoritesDeletionConfirmation: Bool = false
    
    @State var showErrorAlert: Bool = false
    
    var body: some View {
        List {
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.browser,
                    settingName: "Open Links in Browser",
                    isTicked: $openLinksInBrowser
                )
                SelectableSettingsItem(
                    settingIconSystemName: Icons.haptics,
                    settingName: "Haptic Level",
                    currentValue: $hapticLevel,
                    options: HapticPriority.allCases
                )
                
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.upvoteOnSave,
                    settingName: "Upvote on Save",
                    isTicked: $upvoteOnSave
                )
            } footer: {
                Text("You may need to restart the app for Upvote on Save changes to take effect.")
            }
            
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.blurNsfw,
                    settingName: "Blur NSFW Content",
                    isTicked: $shouldBlurNsfw
                )
            } footer: {
                VStack(alignment: .leading, spacing: 3) {
                    // swiftlint:disable:next line_length
                    Text("Blurs content flagged as Not Safe For Work until tapped. You can disable NSFW content completely in Account Settings.")
                    
                    // TODO: 0.17 deprecation remove this check
                    if (siteInformation.version ?? .zero) >= .init("0.18.0") {
                        NavigationLink(.settings(.accountGeneral)) {
                            HStack(spacing: 3) {
                                Text("Account Settings")
                                Image(systemName: "chevron.right")
                                    .fontWeight(.semibold)
                                    .imageScale(.small)
                            }
                            .font(.footnote)
                        }
                    }
                }
            }
            
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.attachment,
                    settingName: "Confirm Image Uploads",
                    isTicked: $confirmImageUploads
                )
            } footer: {
                Text("Ask to confirm your choice before uploading an image to your instance.")
            }
            
            Section {
                SelectableSettingsItem(
                    settingIconSystemName: defaultFeed.settingsIconName,
                    settingName: "Default Feed",
                    currentValue: $defaultFeed,
                    options: FeedType.allCases
                )
            } footer: {
                Text("The feed to show by default when you open the app.")
            }
            
            Section {
                SelectableSettingsItem(
                    settingIconSystemName: Icons.connection,
                    settingName: "Internet Speed",
                    currentValue: $internetSpeed,
                    options: InternetSpeed.allCases
                )
            } header: {
                Text("Connection Type")
            } footer: {
                Text("Optimizes performance for your internet speed. You may need to restart the app for all optimizations to take effect.")
            }
            
            Section {
                SelectableSettingsItem(
                    settingIconSystemName: Icons.appLockSettings,
                    settingName: "App Lock",
                    currentValue: $appLock,
                    options: AppLock.allCases
                )
            } header: {
                Text("Privacy")
            } footer: {
                Text("Locks your app with Face ID")
            }

            Section {
                Button(role: .destructive) {
                    isShowingFavoritesDeletionConfirmation.toggle()
                } label: {
                    Label {
                        Text("Delete Community Favorites")
                    } icon: {
                        if showSettingsIcons {
                            Image(systemName: Icons.delete)
                        }
                    }
                    .foregroundColor(.red)
                    .opacity(favoriteCommunitiesTracker.favoritesForCurrentAccount.isEmpty ? 0.6 : 1)
                }
                .disabled(favoriteCommunitiesTracker.favoritesForCurrentAccount.isEmpty)
                .confirmationDialog(
                    "Delete community favorites for this account?",
                    isPresented: $isShowingFavoritesDeletionConfirmation,
                    titleVisibility: .visible
                ) {
                    Button(role: .destructive) {
                        favoriteCommunitiesTracker.clearCurrentFavourites()
                    } label: {
                        Text("Delete all favorites")
                    }
                    
                    Button(role: .cancel) {
                        isShowingFavoritesDeletionConfirmation.toggle()
                    } label: {
                        Text("Cancel")
                    }

                } message: {
                    Text("You cannot undo this action.")
                }

            } footer: {
                Text("Community favorites are stored on-device and are not tied to your Lemmy account.")
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("General")
        .navigationBarColor()
        .hoistNavigation()
        .onChange(of: appLock) { _ in
            if appLock != .disabled, !BiometricUnlock().requestBiometricPermissions() {
                showErrorAlert = true
                Task {
                    await BiometricUnlockState().setUnlockStatus(isUnlocked: true)
                }
                appLock = .disabled
            }
        }
        .alert(isPresented: $showErrorAlert, content: {
            Alert(
                title: Text("Error"),
                message: Text("Unable to enable setting. Please check app permissions."),
                dismissButton: .default(Text("OK"))
            )
        })
    }
}
