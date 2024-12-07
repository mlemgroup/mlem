//
//  ProfileSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-03.
//

import MlemMiddleware
import SwiftUI

struct ProfileSettingsView: View {
    @Environment(Palette.self) var palette
    
    let person: Person4
    @State var displayName: String = ""
    
    @State var bioTextView: UITextView = .init()
    @State var uploadHistory: ImageUploadHistoryManager = .init()
    
    @State var avatarUrl: URL?
    @State var avatarManager: ImageUploadManager = .init()
    
    @State var bannerUrl: URL?
    @State var bannerManager: ImageUploadManager = .init()
    
    init(person: Person4) {
        self.person = person
        self.displayName = person.displayName == person.name ? "" : person.displayName
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
            } footer: {
                Text("The name that is displayed on your profile. This is not the same as your username, which cannot be changed.")
            }
            Section("Biography") {
                MarkdownTextEditor(
                    onChange: { _ in
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
        .scrollDismissesKeyboard(.interactively)
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
                    palette.tertiaryGroupedBackground
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
