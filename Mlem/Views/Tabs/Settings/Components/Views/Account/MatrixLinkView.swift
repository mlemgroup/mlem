//
//  MatrixLinkView.swift
//  Mlem
//
//  Created by Sjmarf on 30/11/2023.
//

import SwiftUI
import Dependencies

struct MatrixLinkView: View {
    @Dependency(\.siteInformation) var siteInformation: SiteInformationTracker
    @Dependency(\.apiClient) var apiClient: APIClient
    @Dependency(\.errorHandler) var errorHandler: ErrorHandler
    
    @State var matrixUserId: String
    
    @State var hasEdited: UserSettingsEditState = .unedited
    
    let matrixIdRegex = /@.+\:.+\..+/
    
    init() {
        @Dependency(\.siteInformation) var siteInformation: SiteInformationTracker
        let user = siteInformation.myUserInfo?.localUserView
        _matrixUserId = State(wrappedValue: user?.person.matrixUserId ?? "")
    }
    
    var matrixIdValid: Bool {
        if matrixUserId.isEmpty {
            return true
        }
        let match = try? matrixIdRegex.wholeMatch(in: matrixUserId)
        return match != nil
    }
    
    var body: some View {
        Form {
            Section {
                VStack {
                    Image("logo.matrix")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100)
                    
                    Text("Link Matrix Account")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color(.systemGroupedBackground))
                
            }
            Section {
                TextField(text: $matrixUserId) {
                    Text("@user:example.com")
                }
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onChange(of: matrixUserId) { newValue in
                    if newValue != siteInformation.myUserInfo?.localUserView.person.matrixUserId ?? "" {
                        hasEdited = .edited
                    }
                }
                .overlay(alignment: .trailing) {
                    if matrixUserId.isNotEmpty {
                        if matrixIdValid {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
            } footer: {
                // swiftlint:disable:next line_length
                Text("Everyone will be able to see your matrix ID, and will be able to send you messages through Lemmy or another matrix client.")
            }
            Link("What is matrix?", destination: URL(string: "https://matrix.org/")!)
        }
        .navigationBarBackButtonHidden(hasEdited != .unedited)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if hasEdited == .edited {
                    Button("Cancel") {
                        hasEdited = .unedited
                        if let user = siteInformation.myUserInfo?.localUserView {
                            matrixUserId = user.person.matrixUserId ?? ""
                        }
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if hasEdited == .edited {
                    Button("Save") {
                        Task {
                            do {
                                // If we want to remove the matrix id we have to send an empty string to the API (as nil indictates that the setting shouldn't be changed). We then set it to nil on our end afterwards.
                                siteInformation.myUserInfo?.localUserView.person.matrixUserId = matrixUserId
                                if let info = siteInformation.myUserInfo {
                                    hasEdited = .updating
                                    try await apiClient.saveUserSettings(myUserInfo: info)
                                    hasEdited = .unedited
                                }
                                if siteInformation.myUserInfo?.localUserView.person.matrixUserId?.isEmpty ?? false {
                                    siteInformation.myUserInfo?.localUserView.person.matrixUserId = nil
                                }
                            } catch {
                                hasEdited = .edited
                                errorHandler.handle(error)
                            }
                        }
                    }
                } else if hasEdited == .updating {
                    ProgressView()
                }
            }
        }
        .hoistNavigation()
    }
}
