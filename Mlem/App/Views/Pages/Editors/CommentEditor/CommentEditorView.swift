//
//  CommentEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 14/07/2024.
//

import ComponentViews
import Haptics
import LemmyMarkdownUI
import MlemMiddleware
import os
import SwiftUI
import Theming

struct CommentEditorView: View {
    private let log: Logger = .mlemLogger()
    
    @Environment(AppState.self) var appState
    @Environment(HapticManager.self) var hapticManager
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.dismiss) var dismiss
    
    @Setting(\.person_showAvatar) private var showPersonAvatar
    @Setting(\.community_showAvatar) private var showCommunityAvatar
    
    enum ResolutionState: Equatable {
        case success, notFound, error(ErrorDetails), resolving
    }
    
    @State var textView: UITextView = .init()

    let commentTreeTracker: CommentTreeTracker?
    
    @State var commentToEdit: Comment2?
    @State var originalContext: Context?
    @State var resolvedContext: Context?
    @State var resolutionState: ResolutionState = .success
    @State var sending: Bool = false

    @State var account: UserAccount
    @State var presentationSelection: PresentationDetent = .large
    
    @State var textIsEmpty: Bool = true
    @State var markdownToolbarEditorModel: MarkdownEditorToolbarModel = .init()
    @State var uploadHistory: ImageUploadHistoryManager = .init()
    @State var slurMatch: String?
    
    @State var slurRegex: Regex<AnyRegexOutput>?
    
    init?(
        commentToEdit: Comment2? = nil,
        context: Context? = nil,
        commentTreeTracker: CommentTreeTracker? = nil
    ) {
        self.commentToEdit = commentToEdit
        self._originalContext = .init(wrappedValue: context)
        self._resolvedContext = .init(wrappedValue: context)
        self.commentTreeTracker = commentTreeTracker
        if let userAccount = (AppState.main.firstAccount as? UserAccount) {
            self._account = .init(wrappedValue: userAccount)
        } else {
            return nil
        }
        self._slurRegex = .init(wrappedValue: AppState.main.firstApi.myInstance?.slurRegex())
        
        textView.text = commentToEdit?.content ?? ""
    }
        
    var minTextEditorHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .body).lineHeight * 4 + 15
    }

    var body: some View {
        CollapsibleSheetView(presentationSelection: $presentationSelection, canDismiss: textIsEmpty) {
            NavigationStack {
                content
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            CloseButtonView(ios18Label: .cancel, requiresConfirmation: !textIsEmpty)
                        }
                        ToolbarItem(placement: .principal) {
                            if AccountsTracker.main.userAccounts.count > 1, commentToEdit == nil {
                                AccountPickerMenu(account: $account) {
                                    HStack(spacing: 3) {
                                        FullyQualifiedLabelView(account, labelStyle: .medium, showAvatar: false)
                                        Image(icon: .general.dropDown)
                                            .symbolVariant(.circle.fill)
                                            .symbolRenderingMode(.hierarchical)
                                            .tint(.themedSecondary)
                                            .imageScale(.small)
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            if sending {
                                ProgressView()
                            } else {
                                shimSendButton
                                // sendButton
                            }
                        }
                    }
                    .background(.themedGroupedBackground)
                    .presentationBackground(.themedGroupedBackground)
            }
            .task(id: account) { await resolveContext() }
        }
        .onDisappear {
            // If we didn't have the `isAlive` check here, the images would
            // get deleted when you click on a link in the reply context
            if !navigation.isAlive, !sending, !uploadHistory.uploads.isEmpty {
                log.debug("Deleting uploaded images...")
                uploadHistory.deleteAll()
            }
        }
        .onChange(of: presentationSelection) {
            if presentationSelection == .large {
                textView.becomeFirstResponder()
            }
        }
        .onChange(of: navigation.isTopSheet) {
            if navigation.isTopSheet, navigation.model != nil {
                textView.becomeFirstResponder()
            }
        }
        .onChange(of: account) {
            if let instance = account.api.myInstance {
                slurRegex = instance.slurRegex()
                checkSlurFilter(text: textView.text)
            } else {
                Task {
                    do {
                        let instance = try await account.api.getMyInstance()
                        slurRegex = instance.slurRegex()
                        checkSlurFilter(text: textView.text)
                    } catch {
                        handleError(error)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                if resolutionState == .notFound {
                    resolutionWarning
                        .padding(.horizontal, 10)
                }
                
                VStack(spacing: Constants.main.standardSpacing) {
                    MarkdownTextEditor(
                        onChange: {
                            if $0.isEmpty != textIsEmpty {
                                textIsEmpty = $0.isEmpty
                            }
                            checkSlurFilter(text: $0)
                        },
                        prompt: "Start writing...",
                        textView: textView,
                        content: {
                            MarkdownEditorToolbarView(
                                textView: textView,
                                uploadHistory: uploadHistory,
                                model: markdownToolbarEditorModel
                            )
                        }
                    )
                    .onChange(of: account.api, initial: true) {
                        markdownToolbarEditorModel.imageUploadApi = account.api
                    }
                    
                    if let slurMatch {
                        FilterViolationWarning(failures: [account.host: slurMatch])
                            .padding(.horizontal, Constants.main.standardSpacing)
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    minHeight: minTextEditorHeight,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .padding(.vertical, Constants.main.standardSpacing)
                .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                .paletteBorder(cornerRadius: Constants.main.standardSpacing)
                .padding(.horizontal, Constants.main.standardSpacing)
                
                contextView
                    .padding(Constants.main.standardSpacing)
                    .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                    .paletteBorder(cornerRadius: Constants.main.standardSpacing)
                    .padding(.horizontal, Constants.main.standardSpacing)
            }
            .animation(.easeOut(duration: 0.2), value: resolutionState == .notFound)
            .padding(.bottom, Constants.main.standardSpacing)
        }
        .scrollBounceBehavior(.basedOnSize)
        .task { await inferContextFromCommentToEdit() }
    }
    
    @ViewBuilder
    var contextView: some View {
        switch originalContext {
        case let .post(post):
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                HStack {
                    FullyQualifiedLinkView(
                        post.community_,
                        labelStyle: .medium,
                        blurred: post.nsfw
                    )
                    Spacer()
                    selectTextButton
                }
                LargePostBodyView(post: post, isPostPage: true, shouldBlur: false)
                FullyQualifiedLinkView(
                    post.creator_,
                    labelStyle: .medium,
                    blurred: post.nsfw
                )
            }
            .onAppear {
                if !(post is any Post2Providing) {
                    Task {
                        originalContext = try await .post(post.upgrade())
                    }
                }
            }
        case let .comment(comment):
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                HStack {
                    FullyQualifiedLinkView(
                        comment.creator_,
                        labelStyle: .small
                    )
                    Spacer()
                    selectTextButton
                }
                CommentBodyView(comment: comment)
            }
            .onAppear {
                if !(comment is any Comment2Providing) {
                    Task {
                        originalContext = try await .comment(comment.upgrade())
                    }
                }
            }
        case let .unifiedPost(post):
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                HStack {
                    ExpectedView(post.community) { community in
                        FullyQualifiedLinkView(
                            community,
                            labelStyle: .medium,
                            blurred: post.nsfw.value ?? true
                        )
                    } placeholder: {
                        Text("placeholder@placeholder")
                            .redacted(reason: .placeholder)
                    }

                    Spacer()
                    selectTextButton
                }
                // LargePostBodyView(post: post, isPostPage: true, shouldBlur: false)
                DevPostView(post: post)
                ExpectedView(post.creator) { creator in
                    FullyQualifiedLinkView(
                        creator,
                        labelStyle: .medium,
                        blurred: post.nsfw.value ?? false
                    )
                } placeholder: {
                    Text("placeholder@placeholder")
                        .redacted(reason: .placeholder)
                }
            }
        case nil:
            ProgressView()
        }
    }
    
    @ViewBuilder
    var selectTextButton: some View {
        Button("Select Text", icon: .general.select) {
            Task { @MainActor in
                textView.resignFirstResponder()
            }
            originalContext?.item.showTextSelectionSheet()
        }
        .labelStyle(.iconOnly)
    }
    
    @ViewBuilder
    var resolutionWarning: some View {
        Text("Failed to resolve post. Try another account.")
            .padding(.vertical, 3)
            .frame(maxWidth: .infinity)
            .background(.opacity(0.2), in: .capsule)
            .foregroundStyle(.themedCaution)
    }
    
    @ViewBuilder
    var shimSendButton: some View {
        switch resolvedContext {
        case let .unifiedPost(post):
            if let id = post.id.value {
                sendButton(id: id)
            }
        default:
            sendButton()
        }
    }
    
    @ViewBuilder
    func sendButton(id: Int = -1) -> some View {
        Button("Send", icon: commentToEdit != nil ? .general.success : .lemmy.send) {
            sending = true
            Task(priority: .userInitiated) {
                await send(id: id)
            }
        }
        .disabled(resolutionState != .success || textIsEmpty || slurMatch != nil)
        .glassProminentButtonStyle()
    }
}
