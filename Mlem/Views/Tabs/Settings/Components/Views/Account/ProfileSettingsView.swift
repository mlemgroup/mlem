//
//  ProfileSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 23/11/2023.
//

import SwiftUI
import Dependencies

struct ProfileSettingsView: View {
    @Dependency(\.siteInformation) var siteInformation: SiteInformationTracker
    @Dependency(\.apiClient) var apiClient: APIClient
    @Dependency(\.errorHandler) var errorHandler: ErrorHandler
    
    enum EditState {
        case unedited, edited, updating
    }
    
    @State var displayName: String = ""
    @State var bio: String = ""
    
    @State var hasEdited: EditState = .unedited
    
    init() {
        if let user = siteInformation.myUserInfo?.localUserView {
            _displayName = State(wrappedValue: user.person.displayName ?? "")
            _bio = State(wrappedValue: user.person.bio ?? "")
        }
    }
    
    var body: some View {
        Form {
            Section {
                TextField(text: $displayName) {
                    Text("(Optional)")
                }
                .accessibilityLabel("Display Name")
                .onChange(of: displayName) { newValue in
                    if newValue != siteInformation.myUserInfo?.localUserView.person.displayName {
                        hasEdited = .edited
                    }
                }
            } header: {
                Text("Display name")
            } footer: {
                Text("The name that is displayed on your profile. This is not the same as your username, which cannot be changed.")
            }
            Section {
                TextField("(Optional)", text: $bio, axis: .vertical)
                    .lineLimit(8, reservesSpace: true)
                    .onChange(of: bio) { newValue in
                        if newValue != siteInformation.myUserInfo?.localUserView.person.bio {
                            hasEdited = .edited
                        }
                    }
            } header: {
                Text("Biography")
            } footer: {
                Text("You can use markdown here.")
            }
            Section {
                Text("Change profile picture / banner will go here")
                    .foregroundStyle(.secondary)
            }
            NavigationLink(.settings(.linkMatrixAccount)) {
                Label("Link Matrix Account", image: "logo.matrix").labelStyle(SquircleLabelStyle(color: .black))
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("My Profile")
        .navigationBarBackButtonHidden(hasEdited != .unedited)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if hasEdited == .edited {
                    Button("Cancel") {
                        hasEdited = .unedited
                        if let user = siteInformation.myUserInfo?.localUserView {
                            displayName = user.person.displayName ?? ""
                            bio = user.person.bio ?? ""
                        }
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if hasEdited == .edited {
                    Button("Save") {
                        Task {
                            do {
                                let displayName = displayName.isNotEmpty ? displayName : nil
                                siteInformation.myUserInfo?.localUserView.person.displayName = displayName
                                siteInformation.myUserInfo?.localUserView.person.bio = bio
                                if let info = siteInformation.myUserInfo {
                                    hasEdited = .updating
                                    try await apiClient.saveUserSettings(myUserInfo: info)
                                    hasEdited = .unedited
                                }
                            } catch {
                                hasEdited = .edited
                                errorHandler.handle(error)
                            }
                        }
                    }
                }
                if hasEdited == .updating {
                    ProgressView()
                }
            }
        }
        .fancyTabScrollCompatible()
    }
}
