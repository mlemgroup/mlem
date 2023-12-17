//
//  ProfileSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 23/11/2023.
//

import SwiftUI
import Dependencies

enum UserSettingsEditState {
    case unedited, edited, updating
}

struct ProfileSettingsView: View {
    @Dependency(\.siteInformation) var siteInformation: SiteInformationTracker
    @Dependency(\.apiClient) var apiClient: APIClient
    @Dependency(\.errorHandler) var errorHandler: ErrorHandler
    
    @State var displayName: String = ""
    @State var bio: String = ""
    
    @StateObject var avatarAttachmentModel: LinkAttachmentModel
    @StateObject var bannerAttachmentModel: LinkAttachmentModel
    
    @State var hasEdited: UserSettingsEditState = .unedited
    
    init() {
        @Dependency(\.siteInformation) var siteInformation: SiteInformationTracker
        let user = siteInformation.myUserInfo?.localUserView
        _displayName = State(wrappedValue: user?.person.displayName ?? "")
        _bio = State(wrappedValue: user?.person.bio ?? "")
        _avatarAttachmentModel = StateObject(wrappedValue: .init(url: user?.person.avatar ?? ""))
        _bannerAttachmentModel = StateObject(wrappedValue: .init(url: user?.person.banner ?? ""))
    }
    
    @ViewBuilder
    func circleImage(systemName: String) -> some View {
        Image(systemName: systemName)
            .frame(width: 48, height: 48)
            .background(Circle().fill(Color(uiColor: .systemGroupedBackground)))
            .foregroundStyle(.blue)
    }
    
    var body: some View {
        Form {
            Section {
                TextField(text: $displayName) {
                    Text("Optional")
                }
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .accessibilityLabel("Display Name")
                .onChange(of: displayName) { newValue in
                    if newValue != siteInformation.myUserInfo?.localUserView.person.displayName ?? "" {
                        hasEdited = .edited
                    }
                }
            } header: {
                Text("Display name")
            } footer: {
                Text("The name that is displayed on your profile. This is not the same as your username, which cannot be changed.")
            }
            Section {
                TextField("Optional", text: $bio, axis: .vertical)
                    .lineLimit(8, reservesSpace: true)
                    .onChange(of: bio) { newValue in
                        if newValue != siteInformation.myUserInfo?.localUserView.person.bio ?? "" {
                            hasEdited = .edited
                        }
                    }
            } header: {
                Text("Biography")
            } footer: {
                Text("You can use markdown here.")
            }
            Section {
                LinkAttachmentView(model: avatarAttachmentModel) {
                    HStack {
                        AvatarView(url: URL(string: avatarAttachmentModel.url), type: .user, avatarSize: 48, iconResolution: .unrestricted)
                        switch avatarAttachmentModel.imageModel?.state {
                        case nil, .uploaded:
                            Text("Avatar")
                                .padding(.leading, 3)
                        default:
                            if let imageModel = avatarAttachmentModel.imageModel {
                                UploadProgressView(imageModel: imageModel)
                                    .padding(.leading, 3)
                            }
                        }
                        Spacer()
                        if avatarAttachmentModel.imageModel != nil || avatarAttachmentModel.url.isNotEmpty {
                            Button(action: avatarAttachmentModel.removeLinkAction) {
                                circleImage(systemName: "xmark")
                            }
                            .buttonStyle(.plain)
                        } else {
                            LinkUploadOptionsView(model: avatarAttachmentModel) {
                                circleImage(systemName: "plus")
                            }
                        }
                    }
                }
                .padding(10)
                .listRowInsets(EdgeInsets())
                .onChange(of: avatarAttachmentModel.url) { newValue in
                    if newValue != siteInformation.myUserInfo?.localUserView.person.avatar ?? "" {
                        hasEdited = .edited
                    }
                }
            }
            Section {
                LinkAttachmentView(model: bannerAttachmentModel) {
                    VStack(spacing: 0) {
                        Group {
                            if bannerAttachmentModel.url.isNotEmpty {
                                CachedImage(url: URL(string: bannerAttachmentModel.url), shouldExpand: false)
                            } else {
                                Color(uiColor: .systemGray5)
                            }
                        }
                        .frame(height: 100)
                        .clipped()
                        HStack {
                            switch bannerAttachmentModel.imageModel?.state {
                            case nil, .uploaded:
                                Text("Banner")
                                    .padding(.leading, 3)
                            default:
                                if let imageModel = bannerAttachmentModel.imageModel {
                                    UploadProgressView(imageModel: imageModel)
                                        .padding(.leading, 3)
                                }
                            }
                            Spacer()
                            if bannerAttachmentModel.imageModel != nil || bannerAttachmentModel.url.isNotEmpty {
                                Button(action: bannerAttachmentModel.removeLinkAction) {
                                    circleImage(systemName: "xmark")
                                }
                                .buttonStyle(.plain)
                            } else {
                                LinkUploadOptionsView(model: bannerAttachmentModel) {
                                    circleImage(systemName: "plus")
                                }
                            }
                        }
                        .padding(10)
                    }
                }
                .listRowInsets(EdgeInsets())
                .onChange(of: bannerAttachmentModel.url) { newValue in
                    if newValue != siteInformation.myUserInfo?.localUserView.person.banner ?? "" {
                        hasEdited = .edited
                    }
                }
          }
            NavigationLink(.settings(.linkMatrixAccount)) {
                Label("Link Matrix Account", image: "logo.matrix").labelStyle(SquircleLabelStyle(color: .black))
                    .disabled(hasEdited != .unedited)
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
                            avatarAttachmentModel.url = user.person.avatar ?? ""
                            bannerAttachmentModel.url = user.person.banner ?? ""
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
                                siteInformation.myUserInfo?.localUserView.person.avatar = avatarAttachmentModel.url
                                siteInformation.myUserInfo?.localUserView.person.banner = bannerAttachmentModel.url
                                if let info = siteInformation.myUserInfo {
                                    hasEdited = .updating
                                    try await apiClient.saveUserSettings(myUserInfo: info)
                                    hasEdited = .unedited
                                }
                            } catch {
                                hasEdited = .edited
                                errorHandler.handle(error)
                            }
                            if displayName.isEmpty {
                                siteInformation.myUserInfo?.localUserView.person.displayName = nil
                            }
                            if avatarAttachmentModel.url.isEmpty {
                                siteInformation.myUserInfo?.localUserView.person.avatar = nil
                            }
                            if bannerAttachmentModel.url.isEmpty {
                                siteInformation.myUserInfo?.localUserView.person.banner = nil
                            }
                        }
                    }
                } else if hasEdited == .updating {
                    ProgressView()
                }
            }
        }
        .fancyTabScrollCompatible()
        .hoistNavigation()
    }
}
