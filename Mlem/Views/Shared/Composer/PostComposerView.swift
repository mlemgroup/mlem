//
//  PostComposerView.swift
//  Mlem
//
//  Created by Sjmarf on 23/07/23
//

import Dependencies
import PhotosUI
import SwiftUI

extension HorizontalAlignment {
    enum LabelStart: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[HorizontalAlignment.leading]
        }
    }
    
    static let labelStart = HorizontalAlignment(LabelStart.self)
}

// swiftlint:disable:next type_body_length
struct PostComposerView: View {
    private enum Field: Hashable {
        case title, url, body
    }
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.pictrsRepository) var pictrsRepository
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.siteInformation) var siteInformation: SiteInformationTracker
    @Dependency(\.hapticManager) var hapticManager
    
    @Environment(\.dismiss) var dismiss
    
    let editModel: PostEditorModel
    
    @AppStorage("promptUser.permission.privacy.allowImageUploads") var askedForPermissionToUploadImages: Bool = false
    @AppStorage("confirmImageUploads") var confirmImageUploads: Bool = false
    
    @State var postTitle: String
    @State var postBody: String
    
    @StateObject var attachmentModel: LinkAttachmentModel
    
    @StateObject var bodyEditorModel: BodyEditorModel = .init()
    @StateObject var inlineAttachmentModel: LinkAttachmentModel

    @State var isNSFW: Bool
    
    @State var isSubmitting: Bool = false
    @State var isShowingErrorDialog: Bool = false
    @State var errorDialogMessage: String = ""
    
    @State var uploadTask: Task<Void, any Error>?
    
    @Environment(\.layoutDirection) var layoutDirection
    
    @FocusState private var focusedField: Field?
    
    @State var titleSlurMatch: String?
    @State var bodySlurMatch: String?
    
    init(editModel: PostEditorModel) {
        self.editModel = editModel
        
        self._postTitle = State(initialValue: editModel.editPost?.post.name ?? "")
        self._postBody = State(initialValue: editModel.editPost?.post.body ?? "")
        self._isNSFW = State(initialValue: editModel.editPost?.post.nsfw ?? false)
        self._attachmentModel = StateObject(wrappedValue: .init(url: editModel.editPost?.post.linkUrl?.description ?? ""))
        self._inlineAttachmentModel = StateObject(wrappedValue: .init(url: ""))
    }

    var body: some View {
            ZStack {
                VStack {
                    Color.clear
                    Color(uiColor: .secondarySystemGroupedBackground)
                }
                .edgesIgnoringSafeArea(.bottom)
                VStack(spacing: 0) {
                    // Community Row
                    headerView
                        .padding(.bottom, 15)
                        .padding(.horizontal)
                        .zIndex(1)
                    
                    VStack(spacing: 15) {
                        TextField("Title", text: $postTitle, axis: .vertical)
                            .font(.title2)
                            .accessibilityLabel("Title")
                            .focused($focusedField, equals: .title)
                            .onAppear {
                                focusedField = .title
                            }
                            .padding(.top)
                            .padding(.horizontal)
                            .onChange(of: postTitle) { newValue in
                                titleSlurMatch = siteInformation.instance?.firstSlurFilterMatch(newValue)
                            }
                        
                        Group {
                            if attachmentModel.imageModel != nil || attachmentModel.url.isNotEmpty {
                                VStack {
                                    let url = URL(string: attachmentModel.url)
                                    if !(url?.isImage ?? true) {
                                        HStack(spacing: AppConstants.postAndCommentSpacing) {
                                            Image(systemName: Icons.websiteAddress)
                                                .foregroundStyle(.blue)
                                                .padding(.leading, 5)
                                            Text(attachmentModel.url)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                            Spacer()
                                            Button(action: attachmentModel.removeLinkAction, label: {
                                                Image(systemName: Icons.close)
                                                    .fontWeight(.semibold)
                                                    .tint(.secondary)
                                                    .padding(5)
                                                    .background(Circle().fill(Color(uiColor: .secondarySystemGroupedBackground)))
                                            })
                                            .padding(5)
                                        }
                                        .padding(10)
                                    } else {
                                        HStack(spacing: AppConstants.postAndCommentSpacing) {
                                            if attachmentModel.url.isNotEmpty {
                                                let url = URL(string: attachmentModel.url)
                                                CachedImage(url: url, shouldExpand: false)
                                                    .frame(
                                                        width: AppConstants.thumbnailSize,
                                                        height: AppConstants.thumbnailSize,
                                                        alignment: .center
                                                    )
                                                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius))
                                            } else {
                                                RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius)
                                                    .fill(.secondary)
                                                    .frame(width: AppConstants.thumbnailSize, height: AppConstants.thumbnailSize)
                                            }
                                            VStack(alignment: .leading) {
                                                if attachmentModel.imageModel?.state == nil {
                                                    Text("Attached Image")
                                                } else {
                                                    if let imageModel = attachmentModel.imageModel {
                                                        Text("Attached Image")
                                                        Spacer()
                                                        UploadProgressView(imageModel: imageModel)
                                                    }
                                                }
                                            }
                                            .frame(height: AppConstants.thumbnailSize - 20)
                                            Spacer()
                                        }
                                        .padding(10)
                                        .overlay(alignment: .topTrailing) {
                                            Button(action: attachmentModel.removeLinkAction, label: {
                                                Image(systemName: Icons.close)
                                                    .fontWeight(.semibold)
                                                    .tint(.secondary)
                                                    .padding(5)
                                                    .background(Circle().fill(Color(uiColor: .secondarySystemGroupedBackground)))
                                            })
                                            .padding(5)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .background {
                                    RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius)
                                        .fill(Color(UIColor.systemGroupedBackground))
                                }
                                .padding(.horizontal)
                            } else {
                                Divider()
                            }
                        }
                        .linkAttachmentModel(model: attachmentModel)
                        
                        BodyEditorView(
                            text: $postBody,
                            prompt: "Body text (optional)",
                            bodyEditorModel: bodyEditorModel,
                            attachmentModel: inlineAttachmentModel
                        )
                        .dynamicTypeSize(.small ... .accessibility2)
                        .accessibilityLabel("Post Body")
                        .focused($focusedField, equals: .body)
                        .padding(.horizontal)
                        .onChange(of: postBody) { newValue in
                            bodySlurMatch = siteInformation.instance?.firstSlurFilterMatch(newValue)
                        }
                        .linkAttachmentModel(model: inlineAttachmentModel)
                        
                        Spacer()
                    }
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 15, topTrailing: 15)))
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: -3)
                }
                
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
            .background(Color(uiColor: .systemGroupedBackground))
            .scrollDismissesKeyboard(.automatic)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .destructive) {
                        attachmentModel.deletePictrs()
                        Task {
                            await bodyEditorModel.deleteAllFiles()
                        }
                        dismiss()
                    }
                    .tint(.red)
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        isNSFW.toggle()
                    } label: {
                        if isNSFW {
                            HStack {
                                Text("NSFW")
                                    .font(.caption)
                                Image(systemName: "eye.trianglebadge.exclamationmark.fill")
                            }
                            .tint(.red)
                        } else {
                            Image(systemName: "eye.fill")
                                .tint(Color(uiColor: .systemGray2))
                        }
                    }
                    .accessibilityLabel("Toggle NSFW")
                    Menu {
                        Button(action: attachmentModel.attachImageAction) {
                            Label("Photo Library", systemImage: Icons.choosePhoto)
                        }
                        Button(action: attachmentModel.attachFileAction) {
                            Label("Choose File", systemImage: Icons.chooseFile)
                        }
                        Button(action: attachmentModel.pasteFromClipboardAction) {
                            Label("Paste", systemImage: Icons.paste)
                        }
                        Divider()
                        LinkUploadOptionsView(model: inlineAttachmentModel) {
                            Label("Inline...", systemImage: "text.below.photo")
                        }
                    } label: {
                        Label("Attach Image or Link", systemImage: Icons.websiteAddress)
                    }
                    // Submit Button
                    Button {
                        Task(priority: .background) {
                            await bodyEditorModel.deleteUnusedFiles(text: postBody)
                        }
                        Task(priority: .userInitiated) {
                            await submitPost()
                        }
                    } label: {
                        Image(systemName: Icons.send)
                    }.disabled(isSubmitting || !isReadyToPost)
                }
            }
        
        .interactiveDismissDisabled(hasPostContent)
        .alert("Submit Failed", isPresented: $isShowingErrorDialog) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorDialogMessage)
        }
        .navigationBarColor()
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    var headerView: some View {
        HStack {
            CommunityLabelView(
                community: editModel.community,
                serverInstanceLocation: .bottom,
                overrideShowAvatar: true
            )
            Spacer()
            if let person = siteInformation.myUserInfo?.localUserView.person {
                UserLabelView(
                    person: person,
                    serverInstanceLocation: .bottom,
                    overrideShowAvatar: true,
                    bannedFromCommunity: false
                )
                .environment(\.layoutDirection, layoutDirection == .leftToRight ? .rightToLeft : .leftToRight)
            }
        }
        .overlay {
            switch inlineAttachmentModel.imageModel?.state {
            case .uploading(progress: let progress):
                infoCapsule(color: Color(uiColor: .secondarySystemBackground)) {
                    HStack(spacing: 20) {
                        if progress == 1 {
                            Text("Processing...")
                            ProgressView()
                        } else {
                            Text("Uploading")
                                .foregroundStyle(.white)
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .frame(width: 80, height: 10)
                        }
                    }
                }
                .padding(-2)
            case .failed(let message):
                infoCapsule(color: .red) {
                    Text("Failed to upload")
                        .foregroundStyle(.white)
                }
            default:
                if let slurMatch = titleSlurMatch == nil ? bodySlurMatch : titleSlurMatch {
                    infoCapsule(color: .red) {
                        Text("\"\(slurMatch)\" is disallowed.")
                            .foregroundStyle(.white)
                    }
                }
            }
            
        }
        .animation(.default, value: titleSlurMatch == nil && bodySlurMatch == nil)
        .animation(.default, value: inlineAttachmentModel.imageModel?.state)
    }
    
    @ViewBuilder
    func infoCapsule(color: Color, @ViewBuilder _ content: () -> some View) -> some View {
        ZStack {
            Capsule()
                .fill(color)
            content()
        }
        .padding(-2)
    }
}
