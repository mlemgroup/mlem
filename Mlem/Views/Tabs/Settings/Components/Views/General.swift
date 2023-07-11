//
//  General.swift
//  Mlem
//
//  Created by David Bureš on 19.05.2023.
//

import SwiftUI
import Nuke

internal enum FavoritesPurgingError {
    case failedToDeleteOldFavoritesFile, failedToCreateNewEmptyFile
}

struct GeneralSettingsView: View {
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
    @AppStorage("defaultCommentSorting") var defaultCommentSorting: CommentSortType = .top
    @AppStorage("defaultFeed") var defaultFeed: FeedType = .subscribed

    @EnvironmentObject var favoritesTracker: FavoriteCommunitiesTracker
    @EnvironmentObject var appState: AppState

    @State private var isShowingFavoritesDeletionConfirmation: Bool = false
    @State private var diskUsage: Int64 = 0

    var body: some View {
        List {

            SelectableSettingsItem(
                settingIconSystemName: "arrow.right.circle",
                settingName: "Default Feed",
                currentValue: $defaultFeed,
                options: FeedType.allCases
            )
            
            Section("Default Sorting") {
                HStack {
                    Image(systemName: "text.line.first.and.arrowtriangle.forward")
                        .foregroundColor(.pink)
                    Text("Posts")
                    Spacer()
                    PostSortMenu(selectedSortingOption: $defaultPostSorting, shortLabel: true)
                }
                
                HStack {
                    Image(systemName: "text.line.first.and.arrowtriangle.forward")
                        .foregroundColor(.pink)
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
            }

            Section {
                Button(role: .destructive) {
                    isShowingFavoritesDeletionConfirmation.toggle()
                } label: {
                    Label("Delete favorites", systemImage: "trash")
                        .foregroundColor(.red)
                }
                .disabled(favoritesTracker.favoriteCommunities.isEmpty)
                .confirmationDialog(
                    "Delete favorites for all accounts?",
                    isPresented: $isShowingFavoritesDeletionConfirmation,
                    titleVisibility: .visible) {
                        Button(role: .destructive) {
                            do {
                                try FileManager.default.removeItem(at: AppConstants.favoriteCommunitiesFilePath)

                                do {
                                    try createEmptyFile(at: AppConstants.favoriteCommunitiesFilePath)

                                    favoritesTracker.favoriteCommunities = .init()
                                } catch let emptyFileCreationError {
                                    appState.contextualError = .init(
                                        title: "Couldn't recreate favorites file",
                                        message: "Try restarting Mlem.",
                                        underlyingError: emptyFileCreationError
                                    )
                                    
                                    print("Failed while creting empty file: \(emptyFileCreationError)")
                                }
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
                    Text("Would you like to delete all your favorited communities for all accounts?\nYou cannot undo this action.")
                }

            }

            Section {
                Button(role: .destructive) {
                    URLCache.shared.removeAllCachedResponses()
                    ImagePipeline.shared.cache.removeAll()
                    diskUsage = Int64(URLCache.shared.currentDiskUsage)
                } label: {
                    Label("Cache: \(ByteCountFormatter.string(fromByteCount: diskUsage, countStyle: .file))", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
            header: {
                Text("Disk Usage")
            }
            footer: {
                Text("All images are cached for fast reuse.")
            }

        }
        .onAppear {
            diskUsage = Int64(URLCache.shared.currentDiskUsage)
        }
        .refreshable {
            diskUsage = Int64(URLCache.shared.currentDiskUsage)
        }
    }
}
