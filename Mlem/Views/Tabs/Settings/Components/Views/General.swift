//
//  General.swift
//  Mlem
//
//  Created by David Bureš on 19.05.2023.
//

import SwiftUI
import LocalAuthentication

internal enum FavoritesPurgingError {
    case failedToDeleteOldFavoritesFile, failedToCreateNewEmptyFile
}

struct GeneralSettingsView: View {
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
    @AppStorage("defaultCommentSorting") var defaultCommentSorting: CommentSortType = .top

    @EnvironmentObject var favoritesTracker: FavoriteCommunitiesTracker
    @EnvironmentObject var accountsTracker: SavedAccountTracker
    @EnvironmentObject var appState: AppState

    @State private var isShowingFavoritesDeletionConfirmation: Bool = false
    @State private var diskUsage: Int64 = 0
    @State private var context = LAContext()
    @State private var dirtyEditingUserAccount = false

    var authenticationName: String {
        switch context.biometryType {
        case .touchID:
            "TouchID"
        case .faceID:
            "FaceID"
        default:
            "Passcode"
        }
    }

    @State var accountRequiresLock: Bool = false

    var body: some View {
        List {
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

                                    appState.alertTitle = "Couldn't recreate favorites file"
                                    appState.alertMessage = "Try restarting Mlem."
                                    appState.isShowingAlert.toggle()

                                    print("Failed while creting empty file: \(emptyFileCreationError)")
                                }
                            } catch let fileDeletionError {
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

            if let account = appState.currentActiveAccount {
                Section {
                    SwitchableSettingsItem(
                        settingPictureSystemName: "lock",
                        settingPictureColor: .pink,
                        settingName: "Require \(authenticationName)",
                        isTicked: $accountRequiresLock
                    )
                    .onChange(of: accountRequiresLock) { newValue in
                        if dirtyEditingUserAccount { return }
                        dirtyEditingUserAccount = true
                        Task(priority: .userInitiated) {
                            do {
                                var allowChangeLockState = false
                                let accountLocked = newValue
                                if newValue == true {
                                    var error: NSError?
                                    allowChangeLockState = context.canEvaluatePolicy(
                                        .deviceOwnerAuthentication,
                                        error: &error
                                    )
                                } else {
                                    allowChangeLockState =
                                        try await context.evaluatePolicy(
                                            .deviceOwnerAuthentication,
                                            localizedReason: "Remove the account lock"
                                        )
                                }
                                if allowChangeLockState {
                                    var oldSettings = accountsTracker.accountPreferences[account.id]
                                            ?? AccountPreference(requiresSecurity: false)
                                    oldSettings.requiresSecurity = accountLocked
                                    accountsTracker.accountPreferences.updateValue(oldSettings, forKey: account.id)
                                    dirtyEditingUserAccount = false
                                    return
                                }
                            } catch {}
                            // if all went well we shouldn't get here
                            //                               await MainActor.run {
                            accountRequiresLock = !newValue
                            dirtyEditingUserAccount = false
                            //                               }
                        }
                    }
                    .onAppear {
                        accountRequiresLock = accountsTracker.accountPreferences[account.id]?.requiresSecurity ?? false
                    }
                } header: {
                    Label("Account settings", systemImage: "person")
                }
            }

            Section {
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
