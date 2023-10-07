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
    
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    
    @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
    
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
    @AppStorage("defaultCommentSorting") var defaultCommentSorting: CommentSortType = .top
    @AppStorage("defaultFeed") var defaultFeed: FeedType = .subscribed
    
    @AppStorage("hapticLevel") var hapticLevel: HapticPriority = .low
    @AppStorage("upvoteOnSave") var upvoteOnSave: Bool = false
    
    @AppStorage("showSettingsIcons") var showSettingsIcons: Bool = false

    @EnvironmentObject var appState: AppState

    @State private var isShowingFavoritesDeletionConfirmation: Bool = false

    var body: some View {
        List {
            Section {
                SelectableSettingsItem(
                    settingIconSystemName: Icons.haptics,
                    settingName: "Haptic Level",
                    currentValue: $hapticLevel,
                    options: HapticPriority.allCases
                )
                
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.upvoteOnSave,
                    settingName: "Upvote On Save",
                    isTicked: $upvoteOnSave
                )
            } header: {
                Text("Behavior")
            } footer: {
                Text("You may need to restart the app for upvote-on-save changes to take effect.")
            }
            
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.blurNsfw,
                    settingName: "Blur NSFW Content",
                    isTicked: $shouldBlurNsfw
                )
            } footer: {
                // swiftlint:disable line_length
                Text("Blurs content flagged as Not Safe For Work until tapped. You can disable NSFW content from appearing entirely in Account Settings on \(appState.currentActiveAccount?.instanceLink.host ?? "your instance's webpage").")
                // swiftlint:enable line_length
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
                    settingIconSystemName: defaultPostSorting.iconName,
                    settingName: "Posts",
                    currentValue: $defaultPostSorting,
                    options: PostSortType.allCases
                )
                
                SelectableSettingsItem(
                    settingIconSystemName: defaultCommentSorting.iconName,
                    settingName: "Comments",
                    currentValue: $defaultCommentSorting,
                    options: CommentSortType.allCases
                )
            } header: {
                Text("Default Sorting")
            } footer: {
                Text("The sort mode that is selected by default when you open the app.")
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
    }
}
