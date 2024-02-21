//
//  SignInAndSecuritySettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 01/12/2023.
//

import Dependencies
import SwiftUI

struct SignInAndSecuritySettingsView: View {
    @Dependency(\.errorHandler) var errorHandler: ErrorHandler
    
    @State var email: String = ""
    @State var hasEdited: UserSettingsEditState = .unedited
    
    @State var showingChangePasswordSheet: Bool = false
    
    init() {
//        if let user = siteInformation.myUserInfo?.localUserView.localUser {
//            _email = State(wrappedValue: user.email ?? "")
//        }
    }
    
    let emailRegex = /.+@.+\..+/
    
    var emailValid: Bool {
        if email.isEmpty {
            return true
        }
        let match = try? emailRegex.wholeMatch(in: email)
        return match != nil
    }
    
    var body: some View {
        Form {
            Section {
                TextField(text: $email) {
                    Text("Optional")
                }
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onChange(of: email) {
//                    if newValue != siteInformation.myUserInfo?.localUserView.localUser.email {
//                        hasEdited = .edited
//                    }
                }
            } header: {
                Text("Email")
            } footer: {
                Text("PLACEHOLDER")
//                if email.isEmpty {
//                    Text("No email")
//                } else if !emailValid {
//                    HStack {
//                        Image(systemName: "xmark.circle.fill")
//                        Text("Email invalid")
//                    }
//                    .foregroundStyle(.red)
//
//                } else if hasEdited == .unedited, !(siteInformation.myUserInfo?.localUserView.localUser.email?.isEmpty ?? true) {
//                    if siteInformation.myUserInfo?.localUserView.localUser.emailVerified ?? false {
//                        HStack {
//                            Image(systemName: "checkmark.circle.fill")
//                            Text("Email verified")
//                        }
//                        .foregroundStyle(.green)
//                    } else {
//                        HStack {
//                            Image(systemName: "ellipsis.circle.fill")
//                            Text("Email unverified")
//                        }
//                        .foregroundStyle(.orange)
//                    }
//                } else if hasEdited != .unedited {
//                    HStack {
//                        Image(systemName: "checkmark.circle.fill")
//                        Text("Email valid")
//                    }
//                    .foregroundStyle(.green)
//                }
            }
            Button("Change Password") { showingChangePasswordSheet.toggle() }
                .sheet(isPresented: $showingChangePasswordSheet) {
                    ChangePasswordView()
                }
        }
        .navigationTitle("Sign-In & Security")
        .navigationBarBackButtonHidden(hasEdited != .unedited)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if hasEdited == .edited {
                    Button("Cancel") {
                        hasEdited = .unedited
//                        if let user = siteInformation.myUserInfo?.localUserView {
//                            email = user.localUser.email ?? ""
//                        }
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if hasEdited == .edited {
                    Button("Save") {
//                        Task {
//                            do {
//                                // If we want to remove the account email we have to send an empty string to the API (as nil indictates that the setting shouldn't be changed). We then set it to nil on our end afterwards.
//                                siteInformation.myUserInfo?.localUserView.localUser.email = email
//                                if let info = siteInformation.myUserInfo {
//                                    hasEdited = .updating
//                                    try await apiClient.saveUserSettings(myUserInfo: info)
//                                    hasEdited = .unedited
//                                }
//                                if siteInformation.myUserInfo?.localUserView.localUser.email?.isEmpty ?? false {
//                                    siteInformation.myUserInfo?.localUserView.localUser.email = nil
//                                }
//                            } catch {
//                                hasEdited = .edited
//                                errorHandler.handle(error)
//                            }
//                        }
                    }
                    .disabled(!emailValid)
                } else if hasEdited == .updating {
                    ProgressView()
                }
            }
        }
        .fancyTabScrollCompatible()
        .hoistNavigation()
    }
}
