//
//  General.swift
//  Mlem
//
//  Created by David Bureš on 19.05.2023.
//

import SwiftUI

internal enum FavoritesPurgingError {
    case failedToDeleteOldFavoritesFile, failedToCreateNewEmptyFile
}

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
                Toggle("Blur NSFW Content", isOn: $shouldBlurNsfw)
            } footer: {
                // swiftlint:disable line_length
                Text("When enabled, Not Safe For Work content will be blurred until you click on it. If you want to disable NSFW content from appearing entirely, you can do so from Account Settings on \(appState.currentActiveAccount.instanceLink.host ?? "your instance's webpage").")
                // swiftlint:enable line_length
            }
            
            Section {
                Picker("Default Feed", selection: $defaultFeed) {
                    ForEach(FeedType.allCases, id: \.self) {
                        Text($0.label)
                    }
                }
            } footer: {
                Text("The feed to show by default when you open the app.")
            }
            
            Section {
                HStack {
                    Text("Posts")
                    Spacer()
                    PostSortMenu(selectedSortingOption: $defaultPostSorting, shortLabel: true)
                }
                
                HStack {
                    Text("Comments")
                    Spacer()
                    Menu {
                        ForEach(CommentSortType.allCases, id: \.self) { type in
                            Button {
                                defaultCommentSorting = type
                            } label: {
                                Label(type.description, systemImage: type.imageName)
                            }
                            .disabled(type == defaultCommentSorting)
                        }

                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: defaultCommentSorting.imageName)
                                .tint(.pink)
                            Text(defaultCommentSorting.description)
                                .tint(.pink)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
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
                }
                .disabled(favoritesTracker.favoriteCommunities.isEmpty)
                .confirmationDialog(
                    "Delete community favorites for all accounts?",
                    isPresented: $isShowingFavoritesDeletionConfirmation,
                    titleVisibility: .visible) {
                        Button(role: .destructive) {
                            do {
                                try FileManager.default.removeItem(at: AppConstants.favoriteCommunitiesFilePath)
                                favoritesTracker.favoriteCommunities = .init()
                            } catch let fileDeletionError {
                                appState.contextualError = .init(
                                    title: "Couldn't delete favorites",
                                    message: "Try restarting Mlem.",
                                    underlyingError: fileDeletionError
                                )
                                
                                print("Failed while deleting favorites: \(fileDeletionError)")
                            }
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
    }
}
