//
//  General.swift
//  Mlem
//
//  Created by David Bureš on 19.05.2023.
//

import SwiftUI

struct GeneralSettingsView: View {
    
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    
    @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
    
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
    @AppStorage("defaultCommentSorting") var defaultCommentSorting: CommentSortType = .top
    @AppStorage("defaultFeed") var defaultFeed: FeedType = .subscribed

    @EnvironmentObject var favoritesTracker: FavoriteCommunitiesTracker
    @EnvironmentObject var appState: AppState

    @State private var isShowingFavoritesDeletionConfirmation: Bool = false

    var body: some View {
        List {
            
            Section {
                SwitchableSettingsItem(settingPictureSystemName: AppConstants.blurNsfwSymbolName,
                                       settingName: "Blur NSFW Content",
                                       isTicked: $shouldBlurNsfw)
            } footer: {
                // swiftlint:disable line_length
                Text("Blurs content flagged as Not Safe For Work until you click on it. If you want to disable NSFW content from appearing entirely, you can do so from Account Settings on \(appState.currentActiveAccount.instanceLink.host ?? "your instance's webpage").")
                // swiftlint:enable line_length
            }
            
            Section {
                SelectableSettingsItem(settingIconSystemName: defaultFeed.settingsIconName,
                                       settingName: "Default Feed",
                                       currentValue: $defaultFeed,
                                       options: FeedType.allCases)
            } footer: {
                Text("The feed to show by default when you open the app.")
            }
            
            Section {
                SelectableSettingsItem(settingIconSystemName: defaultPostSorting.iconName,
                                       settingName: "Posts",
                                       currentValue: $defaultPostSorting,
                                       options: PostSortType.allCases)
                
                SelectableSettingsItem(settingIconSystemName: defaultCommentSorting.iconName,
                                       settingName: "Comments",
                                       currentValue: $defaultCommentSorting,
                                       options: CommentSortType.allCases)
            } header: {
                Text("Default Sorting")
            } footer: {
                Text("The sort mode that is selected by default when you open the app.")
            }
            
            Section {
                SelectableSettingsItem(settingIconSystemName: AppConstants.connectionSymbolName,
                                       settingName: "Internet Speed",
                                       currentValue: $internetSpeed,
                                       options: InternetSpeed.allCases)
            } header: {
                Text("Connection Type")
            } footer: {
                Text("Optimizes performance for your internet speed. You may need to restart the app for all optimizations to take effect.")
            }

            Section {
                Button(role: .destructive) {
                    isShowingFavoritesDeletionConfirmation.toggle()
                } label: {
                    Label("Delete Community Favorites", systemImage: "trash")
                        .foregroundColor(.red)
                        .opacity(favoritesTracker.favoriteCommunities.isEmpty ? 0.6 : 1)
                }
                .disabled(favoritesTracker.favoriteCommunities.isEmpty)
                .confirmationDialog(
                    "Delete community favorites for all accounts?",
                    isPresented: $isShowingFavoritesDeletionConfirmation,
                    titleVisibility: .visible) {
                        Button(role: .destructive) {
                            favoritesTracker.favoriteCommunities = .init()
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
