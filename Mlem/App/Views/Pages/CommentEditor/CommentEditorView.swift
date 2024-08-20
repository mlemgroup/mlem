//
//  CommentEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 14/07/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

<<<<<<<< HEAD:Mlem/App/Views/Pages/ReplyComposerView.swift
struct ReplyComposerView: View {
========
struct CommentEditorView: View {
>>>>>>>> sjmarf/edit:Mlem/App/Views/Pages/CommentEditor/CommentEditorView.swift
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    enum ResolutionState: Equatable {
        case success, notFound, error(ErrorDetails), resolving
    }
    
    let textView: UITextView = .init()

    let expandedPostTracker: ExpandedPostTracker?
    
    @State var commentToEdit: Comment2?
    @State var originalContext: Context?
    @State var resolvedContext: Context?
    @State var resolutionState: ResolutionState = .success
    @State var sending: Bool = false

<<<<<<<< HEAD:Mlem/App/Views/Pages/ReplyComposerView.swift
========
    @State var text: String
>>>>>>>> sjmarf/edit:Mlem/App/Views/Pages/CommentEditor/CommentEditorView.swift
    @State var account: UserAccount
    @State var presentationSelection: PresentationDetent = .large
    
    @State var textIsEmpty: Bool = true
    
    @FocusState var focused: Bool
    
    init?(
        commentToEdit: Comment2? = nil,
        context: Context? = nil,
        expandedPostTracker: ExpandedPostTracker? = nil
    ) {
        self.commentToEdit = commentToEdit
        self.originalContext = context
        self._resolvedContext = .init(wrappedValue: context)
        self.expandedPostTracker = expandedPostTracker
        if let userAccount = (AppState.main.firstAccount as? UserAccount) {
            self._account = .init(wrappedValue: userAccount)
        } else {
            return nil
        }
        self._text = .init(wrappedValue: commentToEdit?.content ?? "")
        textView.text = text
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
                            Button("Cancel") {
                                dismiss()
                            }
                        }
                        ToolbarItem(placement: .principal) {
                            if AccountsTracker.main.userAccounts.count > 1, commentToEdit == nil {
                                AccountPickerMenu(account: $account) {
                                    HStack(spacing: 3) {
                                        FullyQualifiedLabelView(entity: account, labelStyle: .medium, showAvatar: false)
                                        Image(systemName: "chevron.down.circle.fill")
                                            .symbolRenderingMode(.hierarchical)
                                            .tint(palette.secondary)
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
                                Button("Send", systemImage: Icons.send) {
                                    sending = true
                                    Task(priority: .userInitiated) {
                                        await send()
                                    }
                                }
                                .disabled(resolutionState != .success || textIsEmpty)
                            }
                        }
                    }
            }
            .task(id: account, resolveContext)
        }
        .onAppear {
            textView.becomeFirstResponder()
        }
        .onChange(of: presentationSelection) {
            if presentationSelection == .large {
                textView.becomeFirstResponder()
            }
        }
    }
    
    @ViewBuilder
    var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if resolutionState == .notFound {
                    resolutionWarning
                        .padding([.horizontal, .bottom], 10)
                }
                MarkdownTextEditor(
                    onChange: {
                        if $0.isEmpty != textIsEmpty {
                            textIsEmpty = $0.isEmpty
                        }
                    },
                    prompt: "Start writing...",
                    textView: textView,
                    content: {
                        MarkdownEditorToolbarView(textView: textView)
                    }
                )
                .frame(
                    maxWidth: .infinity,
                    minHeight: minTextEditorHeight,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                Divider()
                    .padding(.vertical, Constants.main.standardSpacing)
                Group {
                    switch originalContext {
                    case let .post(post):
                        LargePostBodyView(post: post, isExpanded: true)
                    case let .comment(comment):
                        CommentBodyView(comment: comment)
                    case nil:
                        ProgressView()
                            .task(inferContextFromCommentToEdit)
                    }
                }.padding(.horizontal, Constants.main.standardSpacing)
            }
            .animation(.easeOut(duration: 0.2), value: resolutionState == .notFound)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
    
    @ViewBuilder
    var resolutionWarning: some View {
        Text("Failed to resolve post. Try another account.")
            .padding(.vertical, 3)
            .frame(maxWidth: .infinity)
            .background(.opacity(0.2), in: .capsule)
            .foregroundStyle(palette.caution)
    }
<<<<<<<< HEAD:Mlem/App/Views/Pages/ReplyComposerView.swift
    
    @Sendable
    func resolveContext() async {
        do {
            if originalContext.api === account.api {
                resolutionState = .success
                resolvedContext = originalContext
            } else {
                Task { @MainActor in
                    resolutionState = .resolving
                }
                switch originalContext {
                case let .post(post):
                    let post = try await account.api.getPost(actorId: post.actorId)
                    Task { @MainActor in
                        resolutionState = .success
                        resolvedContext = .post(post)
                    }
                case let .comment(comment):
                    let comment = try await account.api.getComment(actorId: comment.actorId)
                    Task { @MainActor in
                        resolutionState = .success
                        resolvedContext = .comment(comment)
                    }
                }
            }
            
        } catch ApiClientError.noEntityFound {
            print("No entity found!")
            Task { @MainActor in
                resolutionState = .notFound
            }
        } catch {
            Task { @MainActor in
                resolutionState = .error(.init(error: error))
            }
        }
    }
    
    func send() async {
        do {
            let result: Comment2
            let parent: (any Comment2Providing)?
            switch resolvedContext {
            case let .post(post):
                result = try await post.reply(content: textView.text)
                parent = nil
            case let .comment(comment):
                result = try await comment.reply(content: textView.text)
                parent = comment
            }
            Task { @MainActor in
                textView.resignFirstResponder()
                textView.isEditable = false
                HapticManager.main.play(haptic: .success, priority: .low)
                print("EXP", expandedPostTracker == nil)
                expandedPostTracker?.insertCreatedComment(result, parent: parent)
                dismiss()
            }
        } catch {
            Task { @MainActor in
                sending = false
                textView.isEditable = true
                handleError(error)
            }
        }
    }
}

enum ResponseContext: Hashable {
    case post(any Post2Providing)
    case comment(any Comment2Providing)
    
    static func == (lhs: ResponseContext, rhs: ResponseContext) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .post(post):
            hasher.combine("post")
            hasher.combine(post.hashValue)
        case let .comment(comment):
            hasher.combine("comment")
            hasher.combine(comment.hashValue)
        }
    }
    
    var api: ApiClient {
        switch self {
        case let .post(post):
            post.api
        case let .comment(comment):
            comment.api
        }
    }
========
>>>>>>>> sjmarf/edit:Mlem/App/Views/Pages/CommentEditor/CommentEditorView.swift
}
