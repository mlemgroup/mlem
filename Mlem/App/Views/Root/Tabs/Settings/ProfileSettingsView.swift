//
//  ProfileSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-03.
//

import ComponentViews
import MlemMiddleware
import SwiftUI

struct ProfileSettingsView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    @Environment(\.palette) var palette
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    let person: Person4

    @State var profileDetails: ProfileDetails
    
    @State var bioTextView: UITextView = .init()
    @State var markdownToolbarEditorModel: MarkdownEditorToolbarModel = .init()
    @State var uploadHistory: ImageUploadHistoryManager = .init()
    
    @State var avatarManager: ImageUploadManager = .init()
    @State var bannerManager: ImageUploadManager = .init()
    
    @State var isSubmitting: Bool = false
    
    init(person: Person4) {
        self.person = person
        self._profileDetails = .init(wrappedValue: person.profileDetails())
        bioTextView.text = person.description ?? ""
    }

    var displayNameText: Binding<String> {
        .init(get: {
            profileDetails.displayName ?? ""
        }, set: { newValue in
            if newValue == person.displayName || newValue.isEmpty {
                profileDetails.displayName = nil
            }
        })
    }
    
    var minTextEditorHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .body).lineHeight * 6 + 20
    }
    
    var body: some View {
        Form {
            if person.api.supports(.editDisplayName, defaultValue: true) {
                displayNameSection
            }
            Section("Biography") {
                MarkdownTextEditor(
                    onChange: { profileDetails.description = $0 },
                    prompt: "Write a bit about yourself...",
                    textView: bioTextView,
                    insets: .init(
                        top: Constants.main.standardSpacing,
                        left: Constants.main.standardSpacing,
                        bottom: Constants.main.standardSpacing,
                        right: Constants.main.standardSpacing
                    ),
                    firstResponder: false,
                    sizingOffset: 10,
                    content: {
                        MarkdownEditorToolbarView(
                            textView: bioTextView,
                            uploadHistory: uploadHistory,
                            model: markdownToolbarEditorModel
                        )
                    }
                )
                .frame(
                    maxWidth: .infinity,
                    minHeight: minTextEditorHeight,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .listRowInsets(.init())
            }
            avatarSection
            bannerSection
        }
        .onAppear {
            markdownToolbarEditorModel.imageUploadApi = person.api
        }
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .navigationBarBackButtonHidden(showToolbarOptions)
        .interactiveDismissDisabled(showToolbarOptions)
        .toolbar {
            if showToolbarOptions {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        profileDetails = person.profileDetails()
                        bioTextView.text = profileDetails.description
                    } label: {
                        if #available(iOS 26, *) {
                            Label("Discard", icon: .general.delete)
                        } else {
                            Text("Cancel")
                        }
                    }
                    .disabled(isSubmitting)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        saveButtonView
                    }
                }
            } else if navigation.isInsideSheet {
                CloseButtonToolbarItem()
            }
        }
    }
    
    var showToolbarOptions: Bool { profileDetails != person.profileDetails() }

    @ViewBuilder
    var displayNameSection: some View {
        Section("Display Name") {
            TextField("Display Name", text: displayNameText, prompt: Text(person.name))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        } footer: {
            Text("The name that is displayed on your profile. This is not the same as your username, which cannot be changed.")
        }
    }
    
    @ViewBuilder
    var avatarSection: some View {
        Section {
            HStack(spacing: 15) {
                CircleCroppedImageView(url: profileDetails.avatar, frame: 48, fallback: .personAvatar)
                Text("Avatar")
                Spacer()
                CircleImageUploadButton(imageManager: avatarManager, url: $profileDetails.avatar, api: person.api)
            }
            .onChange(of: avatarManager.image?.url) {
                profileDetails.avatar = avatarManager.image?.url
            }
        }
    }
    
    @ViewBuilder
    var bannerSection: some View {
        Section {
            VStack(spacing: 0) {
                if let bannerUrl = profileDetails.banner {
                    MediaView(
                        url: bannerUrl,
                        contentMode: .fill,
                        enableContextMenu: true,
                        enableImageViewer: true
                    )
                    .frame(height: 150)
                    .clipped()
                } else {
                    palette.label.secondary.opacity(0.5)
                        .frame(height: 150)
                }
                HStack(spacing: 15) {
                    Text("Banner")
                    Spacer()
                    CircleImageUploadButton(imageManager: bannerManager, url: $profileDetails.banner, api: person.api)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
            }
            .onChange(of: bannerManager.image?.url) {
                profileDetails.banner = bannerManager.image?.url
            }
        }
        .listRowInsets(.init())
    }
    
    @ViewBuilder
    var saveButtonView: some View {
        Button {
            Task { @MainActor in await submit() }
        } label: {
            if #available(iOS 26, *) {
                Label("Save", icon: .general.success)
            } else {
                Text("Save")
            }
        }
        .glassProminentButtonStyle()
    }
    
    @MainActor
    func submit() async {
        isSubmitting = true
        do {
            try await person.updateProfile(profileDetails)
            if let session = appState.firstSession as? UserSession, session.person === person {
                try await session.updateAccount()
            } else {
                assertionFailure()
            }
            dismiss()
        } catch {
            handleError(error)
        }
        isSubmitting = false
    }
}

private struct CircleImageUploadButton: View {
    let imageManager: ImageUploadManager
    @Binding var url: URL?
    let api: ApiClient
    
    var body: some View {
        Group {
            if url != nil {
                Button {
                    url = nil
                } label: {
                    Image(icon: .general.delete)
                        .resizable()
                        .symbolVariant(.circle.fill)
                }
            } else {
                switch imageManager.state {
                case .uploading:
                    ProgressView()
                        .controlSize(.extraLarge)
                default:
                    ImageUploadMenu(imageManager: imageManager, imageUploadApi: api) {
                        Image(icon: .general.add)
                            .resizable()
                            .symbolVariant(.circle.fill)
                    }
                }
            }
        }
        .aspectRatio(contentMode: .fit)
        .frame(height: 36)
        .symbolRenderingMode(.hierarchical)
        .fontWeight(.regular)
    }
}
