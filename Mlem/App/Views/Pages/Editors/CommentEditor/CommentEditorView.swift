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
import Dependencies
import Combine

// swiftlint:disable:next type_body_length
struct CommentEditorView: View {
    private let log: Logger = .mlemLogger()
    
    @Dependency(\.draftsTracker) var draftsTracker
    
    @Environment(AppState.self) var appState
    @Environment(HapticManager.self) var hapticManager
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.dismiss) var dismiss
    
    @Setting(\.person_showAvatar) private var showPersonAvatar
    @Setting(\.community_showAvatar) private var showCommunityAvatar
    @Setting(\.dev_developerMode) private var developerMode
    
    enum ResolutionState: Equatable {
        case success, notFound, error(ErrorDetails), resolving
    }
    
    @State var textView: UITextView = .init()

    let commentTreeTracker: CommentTreeTracker?
    
    @State var commentToEdit: Comment?
    @State var originalContext: Context?
    @State var resolvedContext: Context?
    @State var resolutionState: ResolutionState = .success
    @State var sending: Bool = false

    @State var account: UserAccount
    @State var presentationSelection: PresentationDetent = .large
    @State var language: Locale.Language?
    
    @State var textIsEmpty: Bool = true
    @State var markdownToolbarEditorModel: MarkdownEditorToolbarModel = .init()
    @State var uploadHistory: ImageUploadHistoryManager = .init()
    @State var slurMatch: String?
    @State var slurTask: Task<Void, Never>?

    @State var slurRegex: Regex<AnyRegexOutput>?
    
    @State var draftId: UUID = UUID()
    @State var availableDrafts: [DraftMetadata]?
    @State var draftSaved: Date?
    let dateTimeFormatter: RelativeDateTimeFormatter
    var timer = Timer.publish(every: 0.5, on: .main, in: .common)
        .autoconnect()
    
    init?(
        commentToEdit: Comment? = nil,
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
        
        self.dateTimeFormatter = RelativeDateTimeFormatter()
        self.dateTimeFormatter.unitsStyle = .short
        
        textView.text = commentToEdit?.content.string ?? ""
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
                            CloseButtonView(requiresConfirmation: !textIsEmpty)
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
                                sendButton
                            }
                        }
                    }
                    .background(.themedGroupedBackground)
            }
            .presentationBackground(.themedGroupedBackground)
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
        .onAppear {
            loadAvailableDrafts()
        }
        .onReceive(timer) { _ in
            Task {
                await saveDraft()
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
                    .frame(
                        maxWidth: .infinity,
                        minHeight: minTextEditorHeight,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    )

                    if let ids = account.api.myPerson?.discussionLanguageIds.value, ids.count > 1 {
                        LanguagePickerView(api: account.api, selected: $language)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal, Constants.main.standardSpacing)
                    }

                    if let slurMatch {
                        FilterViolationWarning(failures: [account.host: slurMatch])
                            .padding(.horizontal, Constants.main.standardSpacing)
                    }
                }
                .padding(.vertical, Constants.main.standardSpacing)
                .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                .paletteBorder(cornerRadius: Constants.main.standardSpacing)
                .padding(.horizontal, Constants.main.standardSpacing)
                
                if developerMode {
                    Text("\(draftId)")
                        .font(.footnote)
                        .foregroundStyle(.themedSecondary)
                        .padding(.horizontal, Constants.main.standardSpacing)
                }
                
                if let availableDrafts, !availableDrafts.isEmpty {
                    draftPicker(availableDrafts: availableDrafts)
                        .padding(Constants.main.standardSpacing)
                        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
                        .padding(.horizontal, Constants.main.standardSpacing)
                }
                
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
        .markdownToolbarKeyboardInset([textView])
        .task { await inferContextFromCommentToEdit() }
    }
    
    @ViewBuilder
    var contextView: some View {
        switch originalContext {
        case let .post(post):
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                HStack {
                    ExpectedView(post.community) { community in
                        FullyQualifiedLinkView(
                            community,
                            labelStyle: .medium,
                            blurred: post.nsfw
                        )
                    } placeholder: {
                        Text(verbatim: .communityPlaceholder).redacted(reason: .placeholder)
                    }
                    Spacer()
                    selectTextButton
                }
                LargePostBodyView(post: post, isPostPage: true, shouldBlur: post.nsfw)
                ExpectedView(post.creator) { creator in
                    FullyQualifiedLinkView(
                        creator,
                        labelStyle: .medium,
                        blurred: post.nsfw)
                } placeholder: {
                    Text(verbatim: .personPlaceholder).redacted(reason: .placeholder)
                }
            }
        case let .comment(comment):
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                HStack {
                    ExpectedView(comment.creator) { creator in
                        FullyQualifiedLinkView(
                            creator,
                            labelStyle: .small
                        )
                    } placeholder: {
                        Text(verbatim: .personPlaceholder).redacted(reason: .placeholder)
                    }
                    Spacer()
                    selectTextButton
                }
                CommentBodyView(comment: comment)
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
            if let content = originalContext?.item.selectableContent {
                navigation.openSheet(.selectText(content))
            }
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
    var sendButton: some View {
        Button("Send", icon: commentToEdit != nil ? .general.success : .lemmy.send) {
            sending = true
            Task(priority: .userInitiated) {
                await send()
            }
        }
        .disabled(resolutionState != .success || textIsEmpty || slurMatch != nil)
        .buttonStyle(.glassProminent)
    }
    
    @ViewBuilder
    func draftPicker(availableDrafts: [DraftMetadata]) -> some View {
        VStack {
            ForEach(availableDrafts, id: \.id) { draft in
                HStack {
                    if draft.id == draftId {
                        Image(icon: .general.circle)
                            .symbolVariant(.fill)
                            .foregroundStyle(.themedPositive)
                            .font(.system(size: 10.0))
                            .padding(.trailing, 7)
                    }
                    Text(draft.author.description)
                    Spacer()
                    Text(dateTimeFormatter.localizedString(for: draft.touched, relativeTo: .now))
                    Button("Delete", icon: .general.remove) {
                        Task {
                            await deleteDraft(draft.id)
                        }
                    }
                }
                .contentShape(.rect)
                .onTapGesture {
                    Task {
                        await saveDraft()
                        loadDraft(draft)
                    }
                }
            }
        }
    }
}
