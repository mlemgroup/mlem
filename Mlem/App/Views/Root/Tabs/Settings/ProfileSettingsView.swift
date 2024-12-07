//
//  ProfileSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-03.
//

import MlemMiddleware
import SwiftUI

struct ProfileSettingsView: View {
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    let person: Person4
    @State var displayName: String
    
    @State var bioTextView: UITextView = .init()
    @State var bioHasChanged: Bool = false
    @State var uploadHistory: ImageUploadHistoryManager = .init()
    
    @State var avatarUrl: URL?
    @State var avatarManager: ImageUploadManager = .init()
    
    @State var bannerUrl: URL?
    @State var bannerManager: ImageUploadManager = .init()
    
    @State var isSubmitting: Bool = false
    
    init(person: Person4) {
        self.person = person
        self._displayName = .init(wrappedValue: person.displayName == person.name ? "" : person.displayName)
        bioTextView.text = person.description ?? ""
        self._avatarUrl = .init(wrappedValue: person.avatar)
        self._bannerUrl = .init(wrappedValue: person.banner)
    }
    
    var minTextEditorHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .body).lineHeight * 6 + 20
    }
    
    var body: some View {
        Form {
            Section("Display Name") {
                TextField("Display Name", text: $displayName, prompt: Text(person.name))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            } footer: {
                Text("The name that is displayed on your profile. This is not the same as your username, which cannot be changed.")
            }
            Section("Biography") {
                MarkdownTextEditor(
                    onChange: { newValue in
                        bioHasChanged = (person.description ?? "") != newValue
                    },
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
                            imageUploadApi: person.api
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
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .navigationBarBackButtonHidden(showToolbarOptions)
        .interactiveDismissDisabled(showToolbarOptions)
        .toolbar {
            if showToolbarOptions {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        displayName = person.displayName == person.name ? "" : person.displayName
                        bioTextView.text = person.description ?? ""
                        bioHasChanged = false
                        avatarUrl = person.avatar
                        bannerUrl = person.banner
                    }
                    .disabled(isSubmitting)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task { @MainActor in
                                await submit()
                            }
                        }
                    }
                }
            } else if navigation.isInsideSheet {
                ToolbarItem(placement: .topBarTrailing) {
                    CloseButtonView()
                }
            }
        }
    }
    
    var showToolbarOptions: Bool {
        let originalDisplayName = (person.displayName == person.name) ? "" : person.displayName
        return bioHasChanged || displayName != originalDisplayName || avatarUrl != person.avatar || bannerUrl != person.banner
    }
    
    @ViewBuilder
    var avatarSection: some View {
        Section {
            HStack(spacing: 15) {
                CircleCroppedImageView(url: avatarUrl, frame: 48, fallback: .person)
                    .id(avatarUrl)
                Text("Avatar")
                Spacer()
                CircleImageUploadButton(imageManager: avatarManager, url: $avatarUrl, api: person.api)
            }
            .onChange(of: avatarManager.image?.url) {
                avatarUrl = avatarManager.image?.url
            }
        }
    }
    
    @ViewBuilder
    var bannerSection: some View {
        Section {
            VStack(spacing: 0) {
                if let bannerUrl {
                    LargeImageView(url: bannerUrl, shouldBlur: false, cornerRadius: 0)
                        .id(bannerUrl)
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                } else {
                    palette.secondary.opacity(0.5)
                        .frame(height: 150)
                }
                HStack(spacing: 15) {
                    Text("Banner")
                    Spacer()
                    CircleImageUploadButton(imageManager: bannerManager, url: $bannerUrl, api: person.api)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
            }
            .onChange(of: bannerManager.image?.url) {
                bannerUrl = bannerManager.image?.url
            }
        }
        .listRowInsets(.init())
    }
    
    @MainActor
    func submit() async {
        isSubmitting = true
        do {
            try await person.updateProfile(
                displayName: displayName.isEmpty ? nil : displayName,
                description: bioTextView.text.isEmpty ? nil : bioTextView.text,
                avatar: avatarUrl,
                banner: bannerUrl
            )
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
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                }
            } else {
                switch imageManager.state {
                case .uploading:
                    ProgressView()
                        .controlSize(.extraLarge)
                default:
                    ImageUploadMenu(imageManager: imageManager, imageUploadApi: api) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                    }
                }
            }
        }
        .aspectRatio(contentMode: .fit)
        .frame(height: 48)
        .symbolRenderingMode(.hierarchical)
        .fontWeight(.thin)
    }
}
