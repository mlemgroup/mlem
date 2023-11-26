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
    
    @State var displayName: String = ""
    @State var bio: String = ""
    
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
                .onSubmit {
                    print("UPDATE")
                    Task {
                        do {
                            siteInformation.myUserInfo?.localUserView.person.displayName = displayName.isNotEmpty ? displayName : nil
                            print(siteInformation.myUserInfo?.localUserView.person.displayName)
                            if let info = siteInformation.myUserInfo {
                                let response = try await apiClient.saveUserSettings(myUserInfo: info)
                                print(response)
                            } else {
                                print("NOINFO")
                            }
                        } catch {
                            print("ERROR", error)
                            if case APIClientError.response(let response, let num) = error {
                                print(response, num)
                            }
                        }
                    }
                }
            } header: {
                Text("Display name")
            } footer: {
                Text("The name that is displayed on your profile. Leave blank to use your username as the display name.")
            }
            Section {
                TextField("(Optional)", text: $bio, axis: .vertical)
                    .lineLimit(8, reservesSpace: true)
            } header: {
                Text("Biography")
            } footer: {
                Text("You can use markdown here.")
            }
            Section {
                Text("Changing your Profile Picture & Banner is not yet supported within Mlem.")
                    .foregroundStyle(.secondary)
            }
            NavigationLink { EmptyView() } label: {
                Label("Link Matrix Account", image: "logo.matrix").labelStyle(SquircleLabelStyle(color: .black))
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("My Profile")
        .fancyTabScrollCompatible()
    }
}
