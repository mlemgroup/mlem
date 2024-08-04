//
//  ReplyView.swift
//  Mlem
//
//  Created by Sjmarf on 14/07/2024.
//

import MlemMiddleware
import SwiftUI

struct ResponseComposerView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    enum ResolutionState: Equatable {
        case success, notFound, error(ErrorDetails), resolving
    }
    
    let textView: UITextView = .init()
    
    @State var text: String = ""
    @FocusState var focused: Bool
    
    let originalContext: ResponseContext
    let expandedPostTracker: ExpandedPostTracker?
    @State var resolvedContext: ResponseContext
    @State var resolutionState: ResolutionState = .success
    @State var sending: Bool = false

    @State var account: UserAccount
    @State var presentationSelection: PresentationDetent = .large
    
    init?(
        context: ResponseContext,
        expandedPostTracker: ExpandedPostTracker? = nil
    ) {
        self.originalContext = context
        self.resolvedContext = context
        self.expandedPostTracker = expandedPostTracker
        if let userAccount = (AppState.main.firstAccount as? UserAccount) {
            self._account = .init(wrappedValue: userAccount)
        } else {
            return nil
        }
    }
        
    var minTextEditorHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .body).lineHeight * 4 + 15
    }

    var body: some View {
        CollapsibleSheetView(presentationSelection: $presentationSelection, canDismiss: text.isEmpty) {
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
                                .disabled(resolutionState != .success || text.isEmpty)
                            }
                        }
                    }
            }
            .task(id: account, resolveContext)
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
                    text: $text,
                    prompt: "Start writing...",
                    textView: textView
                ) {
                    MarkdownEditorToolbarView(textView: textView)
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: minTextEditorHeight,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                Divider()
                    .padding(.vertical, AppConstants.standardSpacing)
                switch originalContext {
                case let .post(post):
                    LargePostBodyView(post: post, isExpanded: true)
                        .padding(.horizontal, AppConstants.standardSpacing)
                }
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
    
    @Sendable
    func resolveContext() async {
        do {
            switch originalContext {
            case let .post(post):
                if post.api === account.api {
                    resolutionState = .success
                    resolvedContext = originalContext
                } else {
                    Task { @MainActor in
                        resolutionState = .resolving
                    }
                    let post = try await account.api.getPost(actorId: post.actorId)
                    Task { @MainActor in
                        resolutionState = .success
                        resolvedContext = .post(post)
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
            switch resolvedContext {
            case let .post(post):
                result = try await post.reply(content: text)
            }
            Task { @MainActor in
                textView.resignFirstResponder()
                textView.isEditable = false
                HapticManager.main.play(haptic: .success, priority: .low)
                expandedPostTracker?.insertCreatedComment(result)
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
    
    static func == (lhs: ResponseContext, rhs: ResponseContext) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .post(post):
            hasher.combine("post")
            hasher.combine(post.hashValue)
        }
    }
}
