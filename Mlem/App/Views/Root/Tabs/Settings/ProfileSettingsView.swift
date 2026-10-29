//
//  ProfileSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-03.
//

import ComponentViews
import MlemMiddleware
import SwiftUI
import Theming

struct ProfileSettingsView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(MediaTracker.self) var mediaTracker
    
    @Environment(\.palette) var palette
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    let person: Person

    @State var profileDetails: ProfileDetails
    
    @State var bioTextView: UITextView = .init()
    @State var markdownToolbarEditorModel: MarkdownEditorToolbarModel = .init()
    @State var uploadHistory: ImageUploadHistoryManager = .init()
    
    @State var avatarManager: ImageUploadManager = .init()
    @State var bannerManager: ImageUploadManager = .init()

    enum SubmittingState {
        case idle, uploadingImages, submitting
    }
    
    @State var submittingState: SubmittingState = .idle
    
    init(person: Person) {
        self.person = person
        self._profileDetails = .init(wrappedValue: person.profileDetails())
        bioTextView.text = person.description ?? ""
        avatarManager.setPreviousUpload(person.avatar)
        bannerManager.setPreviousUpload(person.banner)
    }

    var displayNameText: Binding<String> {
        .init(get: {
            profileDetails.displayName ?? ""
        }, set: { newValue in
            if newValue.isEmpty {
                profileDetails.displayName = nil
            } else {
                profileDetails.displayName = newValue
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
                        avatarManager.setPreviousUpload(person.avatar)
                        bannerManager.setPreviousUpload(person.banner)
                    } label: {
                        Label("Discard", icon: .general.delete)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if submittingState != .idle {
                        ProgressView()
                    } else {
                        saveButtonView
                    }
                }
            } else if navigation.isInsideSheet {
                CloseButtonToolbarItem()
            }
        }
        .disabled(submittingState != .idle)
    }
    
    var showToolbarOptions: Bool {
        profileDetails != person.profileDetails()
            || !avatarManager.matchesPreviousUpload(person.avatar)
            || !bannerManager.matchesPreviousUpload(person.banner)
    }

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
                switch avatarManager.state {
                case .done, .previousUpload:
                    CircleCroppedImageView(url: avatarManager.url, frame: 48, fallback: .personAvatar)
                case let .waiting(image), let .uploading(image, progress: _):
                    if let uiImage = UIImage(data: image.data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .clipShape(.circle)
                            .frame(width: 48, height: 48)
                    }
                case .idle:
                    CircleCroppedImageView(url: nil, frame: 48, fallback: .personAvatar)
                }
                Text("Avatar")
                Spacer()
                CircleImageUploadButton(imageManager: avatarManager, api: person.api)
            }
        }
    }
    
    @ViewBuilder
    var bannerSection: some View {
        Section {
            VStack(spacing: 0) {
                bannerImageView
                    .frame(height: 150)
                    .clipped()
                HStack(spacing: 15) {
                    Text("Banner")
                    Spacer()
                    CircleImageUploadButton(imageManager: bannerManager, api: person.api)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
            }
        }
        .listRowInsets(.init())
    }

    @ViewBuilder
    var bannerImageView: some View {
        switch bannerManager.state {
        case .done, .previousUpload:
            MediaView(
                controlState: mediaTracker.controlState(for: bannerManager.url) {
                    .init(url: bannerManager.url, blurred: false, animating: false, muted: true)
                },
                contentMode: .fill,
                enableContextMenu: true,
                enableImageViewer: true
            )
        case let .waiting(image), let .uploading(image, progress: _):
            if let uiImage = UIImage(data: image.data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            }
        case .idle:
            palette.label.secondary.opacity(0.5)
        }

    }
    
    @ViewBuilder
    var saveButtonView: some View {
        Button {
            Task { @MainActor in await submit() }
        } label: {
            Label("Save", icon: .general.success)
        }
        .buttonStyle(.glassProminent)
    }
    
    @MainActor
    func submit() async {
        if avatarManager.isWaiting || bannerManager.isWaiting {
            submittingState = .uploadingImages
        } 
        do {
            // Intentionally skipping the upload confirmation dialogue here.
            // The user had a chance to see the pending images already.
            let shouldUploadAvatar = avatarManager.isWaiting
            let shouldUploadBanner = bannerManager.isWaiting
            async let avatarUpload: Void = avatarManager.uploadIfWaiting(api: person.api)
            async let bannerUpload: Void = bannerManager.uploadIfWaiting(api: person.api)
            _ = try await (avatarUpload, bannerUpload)

            if shouldUploadAvatar {
                profileDetails.avatar = avatarManager.image?.url
            } else if avatarManager.state == .idle {
                profileDetails.avatar = nil
            }
            if shouldUploadBanner {
                profileDetails.banner = bannerManager.image?.url
            } else if bannerManager.state == .idle {
                profileDetails.banner = nil
            }
            submittingState = .submitting
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
        submittingState = .idle
    }
}

private struct CircleImageUploadButton: View {
    let imageManager: ImageUploadManager
    let api: ApiClient
    
    var body: some View {
        Group {
            switch imageManager.state {
            case let .uploading(_, progress):
                ProgressView(value: progress)
                    .progressViewStyle(.circular)
                    .controlSize(.extraLarge)
            case .idle:
                ImageUploadMenu(
                    imageManager: imageManager,
                    imageUploadApi: api,
                    triggerUpload: false
                ) {
                    Image(icon: .general.add)
                        .resizable()
                        .symbolVariant(.circle.fill)
                }
            case .done, .waiting, .previousUpload:
                Button {
                    imageManager.clear()
                } label: {
                    Image(icon: .general.delete)
                        .resizable()
                        .symbolVariant(.circle.fill)
                }
            }

        }
        .aspectRatio(contentMode: .fit)
        .frame(height: 36)
        .symbolRenderingMode(.hierarchical)
        .fontWeight(.regular)
    }
}
