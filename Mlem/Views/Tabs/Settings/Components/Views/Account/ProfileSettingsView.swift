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
    @State var avatarUrl: String = ""
    @State var bannerUrl: String = ""
    
    @State var avatarImageModel: PictrsImageModel?
    @State var bannerImageModel: PictrsImageModel?
    
    @State var hasEdited: UserSettingsEditState = .unedited
    
    init() {
        if let user = siteInformation.myUserInfo?.localUserView {
            _displayName = State(wrappedValue: user.person.displayName ?? "")
            _bio = State(wrappedValue: user.person.bio ?? "")
            _avatarUrl = State(wrappedValue: user.person.avatar ?? "")
            _bannerUrl = State(wrappedValue: user.person.banner ?? "")
        }
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
                LinkAttachmentView(url: $avatarUrl, imageModel: $avatarImageModel) { proxy in
                    HStack {
                        AvatarView(url: URL(string: avatarUrl), type: .user, avatarSize: 48, iconResolution: .unrestricted)
                        switch avatarImageModel?.state {
                        case nil, .uploaded:
                            Text("Avatar")
                                .padding(.leading, 3)
                        default:
                            if let avatarImageModel {
                                UploadProgressView(imageModel: avatarImageModel)
                                    .padding(.leading, 3)
                            }
                        }
                        Spacer()
                        if avatarImageModel != nil || avatarUrl.isNotEmpty {
                            Button(action: proxy.removeLinkAction) {
                                circleImage(systemName: "xmark")
                            }
                            .buttonStyle(.plain)
                        } else {
                            LinkUploadOptionsView(proxy: proxy) {
                                circleImage(systemName: "plus")
                            }
                        }
                    }
                }
                .padding(10)
                .listRowInsets(EdgeInsets())
                .onChange(of: avatarUrl) { newValue in
                    if newValue != siteInformation.myUserInfo?.localUserView.person.avatar ?? "" {
                        hasEdited = .edited
                    }
                }
            }
            Section {
                LinkAttachmentView(url: $bannerUrl, imageModel: $bannerImageModel) { proxy in
                    VStack(spacing: 0) {
                        Group {
                            if bannerUrl.isNotEmpty {
                                CachedImage(url: URL(string: bannerUrl), shouldExpand: false)
                            } else {
                                Color(uiColor: .tertiarySystemGroupedBackground)
                            }
                        }
                        .frame(height: 100)
                        .clipped()
                        HStack {
                            switch bannerImageModel?.state {
                            case nil, .uploaded:
                                Text("Banner")
                                    .padding(.leading, 3)
                            default:
                                if let bannerImageModel {
                                    UploadProgressView(imageModel: bannerImageModel)
                                        .padding(.leading, 3)
                                }
                            }
                            Spacer()
                            if bannerImageModel != nil || bannerUrl.isNotEmpty {
                                Button(action: proxy.removeLinkAction) {
                                    circleImage(systemName: "xmark")
                                }
                                .buttonStyle(.plain)
                            } else {
                                LinkUploadOptionsView(proxy: proxy) {
                                    circleImage(systemName: "plus")
                                }
                            }
                        }
                        .padding(10)
                    }
                }
                .listRowInsets(EdgeInsets())
                .onChange(of: bannerUrl) { newValue in
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
                            avatarUrl = user.person.avatar ?? ""
                            bannerUrl = user.person.banner ?? ""
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
                                siteInformation.myUserInfo?.localUserView.person.avatar = avatarUrl
                                siteInformation.myUserInfo?.localUserView.person.banner = bannerUrl
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
                            if avatarUrl.isEmpty {
                                siteInformation.myUserInfo?.localUserView.person.avatar = nil
                            }
                            if bannerUrl.isEmpty {
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
