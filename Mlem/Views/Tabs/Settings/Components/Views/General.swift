//
//  General.swift
//  Mlem
//
//  Created by David Bureš on 19.05.2023.
//

import SwiftUI

internal enum FavoritesPurgingError
{
    case failedToDeleteOldFavoritesFile, failedToCreateNewEmptyFile
}

struct GeneralSettingsView: View
{
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
    @AppStorage("defaultCommentSorting") var defaultCommentSorting: CommentSortType = .top

    @EnvironmentObject var favoritesTracker: FavoriteCommunitiesTracker
    @EnvironmentObject var appState: AppState

    @State private var isShowingFavoritesDeletionConfirmation: Bool = false
    @State private var diskUsage: Int64 = 0

    var body: some View
    {
        List
        {
            Section("Default Sorting")
            {
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

            Section
            {
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
                            do
                            {
                                try FileManager.default.removeItem(at: AppConstants.favoriteCommunitiesFilePath)

                                do
                                {
                                    try createEmptyFile(at: AppConstants.favoriteCommunitiesFilePath)

                                    favoritesTracker.favoriteCommunities = .init()
                                }
                                catch let emptyFileCreationError
                                {

                                    appState.alertTitle = "Couldn't recreate favorites file"
                                    appState.alertMessage = "Try restarting Mlem."
                                    appState.isShowingAlert.toggle()

                                    print("Failed while creting empty file: \(emptyFileCreationError)")
                                }
                            }
                            catch let fileDeletionError
                            {
                                appState.alertTitle = "Couldn't delete favorites"
                                appState.alertMessage = "Try restarting Mlem."
                                appState.isShowingAlert.toggle()

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

            Section()
            {
                Button(role: .destructive) {
                    URLCache.shared.removeAllCachedResponses()
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
