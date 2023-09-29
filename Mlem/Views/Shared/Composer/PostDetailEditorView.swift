//
//  PostDetailEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 23/07/23
//

import Dependencies
import SwiftUI
import PhotosUI

extension HorizontalAlignment {
    enum LabelStart: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[HorizontalAlignment.leading]
        }
    }
    
    static let labelStart = HorizontalAlignment(LabelStart.self)
}

struct PostDetailEditorView: View {
    private enum Field: Hashable {
        case title, url, body
    }
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.pictrsRepository) var pictrsRepository
    @Dependency(\.errorHandler) var errorHandler
    
    @Environment(\.dismiss) var dismiss
        
    var community: APICommunity
    var onSubmit: () async throws -> Void
    
    @Binding var postTitle: String
    @Binding var postURL: String
    @Binding var postBody: String
    @Binding var isNSFW: Bool
    
    @State var isSubmitting: Bool = false
    @State var isShowingErrorDialog: Bool = false
    @State var errorDialogMessage: String = ""
    
    @State var showingPhotosPicker: Bool = false
    @State var imageSelection: PhotosPickerItem?
    @State var imageModel: PictrsImageModel?
    
    @State var uploadTask: URLSessionUploadTask?
    
    @FocusState private var focusedField: Field?
    
    init(
        community: APICommunity,
        postTitle: Binding<String>,
        postURL: Binding<String>,
        postBody: Binding<String>,
        isNSFW: Binding<Bool>,
        onSubmit: @escaping () async throws -> Void
    ) {
        self.community = community
        _postTitle = postTitle
        _postURL = postURL
        _postBody = postBody
        _isNSFW = isNSFW
        self.onSubmit = onSubmit
    }

    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                // Community Row
                HStack {
                    CommunityLabelView(
                        community: community,
                        serverInstanceLocation: .bottom,
                        overrideShowAvatar: true
                    )
                    Spacer()
                    // NSFW Toggle
                    Toggle(isOn: $isNSFW) {
                        Text("NSFW")
                            .foregroundStyle(.secondary)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .toggleStyle(.switch)
                    .controlSize(.mini)
                    .tint(.red)
                }
                
                VStack(alignment: .labelStart) {
                    // Title Row
                    HStack {
                        Text("Title")
                            .foregroundColor(.secondary)
                            .dynamicTypeSize(.small ... .accessibility2)
                            .accessibilityHidden(true)
                        TextField("Your post title", text: $postTitle)
                            .lineLimit(AppConstants.textFieldVariableLineLimit)
                            .alignmentGuide(.labelStart) { $0[HorizontalAlignment.leading] }
                            .dynamicTypeSize(.small ... .accessibility2)
                            .accessibilityLabel("Title")
                            .focused($focusedField, equals: .title)
                            .onAppear {
                                focusedField = .title
                            }
                    }
                }
                    
                // URL Row
                if let imageModel = imageModel {
                    ImageUploadView(imageModel: imageModel, onCancel: {
                        if let task = self.uploadTask {
                            task.cancel()
                        }
                        switch imageModel.state {
                        case .uploaded(file: let file):
                            if let file = file {
                                Task {
                                    try await apiClient.deleteImage(file: file)
                                }
                            }
                        default:
                            break
                        }
                        imageSelection = nil
                        self.imageModel = nil
                        postURL = ""
                    })
                } else {
                    VStack(alignment: .labelStart) {
                        HStack {
                            Text("URL")
                                .foregroundColor(.secondary)
                                .dynamicTypeSize(.small ... .accessibility2)
                                .accessibilityHidden(true)
                            
                            TextField("Your post link (Optional)", text: $postURL)
                                .alignmentGuide(.labelStart) { $0[HorizontalAlignment.leading] }
                                .dynamicTypeSize(.small ... .accessibility2)
                                .keyboardType(.URL)
                                .autocorrectionDisabled()
                                .autocapitalization(.none)
                                .accessibilityLabel("URL")
                                .focused($focusedField, equals: .url)
                            
                            Button {
                                showingPhotosPicker = true
                            } label: {
                                Image(systemName: "paperclip")
                                    .font(.title3)
                                    .dynamicTypeSize(.medium)
                            }
                             .accessibilityLabel("Upload Image")
                        }
                    }
                }

                // Post Text
                TextField(
                    "What do you want to say? (Optional)",
                    text: $postBody,
                    axis: .vertical
                )
                .dynamicTypeSize(.small ... .accessibility2)
                .accessibilityLabel("Post Body")
                .focused($focusedField, equals: .body)
                
                Spacer()
            }
            .padding()
            
            // Loading Indicator
            if isSubmitting {
                ZStack {
                    Color.gray.opacity(0.3)
                    ProgressView()
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Submitting Post")
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false)
            }
        }
        .scrollDismissesKeyboard(.automatic)
        .navigationTitle("New Post")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel", role: .destructive) {
                    dismiss()
                }
                .tint(.red)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                // Submit Button
                Button {
                    Task(priority: .userInitiated) {
                        await submitPost()
                    }
                } label: {
                    Image(systemName: Icons.send)
                }.disabled(isSubmitting || !isReadyToPost)
            }
        }
        .alert("Submit Failed", isPresented: $isShowingErrorDialog) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorDialogMessage)
        }
        .navigationBarColor()
        .navigationBarTitleDisplayMode(.inline)
        .photosPicker(isPresented: $showingPhotosPicker, selection: $imageSelection, matching: .images)
        .onChange(of: imageSelection) { newValue in
            if let selection = newValue {
                self.imageModel = .init()
                Task {
                    self.uploadTask = try await pictrsRepository.uploadImage(
                        imageModel: .init(),
                        imageSelection: selection,
                        onUpdate: { newValue in
                            self.imageModel = newValue
                            switch newValue.state {
                            case .uploaded(let file):
                                if let file = file {
                                    do {
                                        var components = URLComponents()
                                        components.scheme = try apiClient.session.instanceUrl.scheme
                                        components.host = try apiClient.session.instanceUrl.host
                                        components.path = "/pictrs/image/\(file.file)"
                                        postURL = components.url?.absoluteString ?? ""
                                    } catch {
                                        self.imageModel?.state = .failed(nil)
                                    }
                                } else {
                                    
                                }
                            default:
                                postURL = ""
                            }
                        }
                    )
                }
            }
        }
    }
}
