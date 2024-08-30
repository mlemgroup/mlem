//
//  CommentEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 14/07/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct CommentEditorView: View {
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
        
        textView.text = commentToEdit?.content ?? ""
        textView.backgroundColor = UIColor(Palette.main.background)
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
                                        FullyQualifiedLabelView(entity: account, labelStyle: .medium, showAvatar: false, blurred: false)
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
                    .background(palette.background)
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
                PaletteDivider()
                    .padding(.vertical, Constants.main.standardSpacing)
                Group {
                    switch originalContext {
                    case let .post(post):
                        LargePostBodyView(post: post, isExpanded: true, shouldBlur: false)
                    case let .comment(comment):
                        CommentBodyView(comment: comment)
                    case nil:
                        ProgressView()
                    }
                }.padding(.horizontal, Constants.main.standardSpacing)
            }
            .animation(.easeOut(duration: 0.2), value: resolutionState == .notFound)
        }
        .scrollBounceBehavior(.basedOnSize)
        .task(inferContextFromCommentToEdit)
    }
    
    @ViewBuilder
    var resolutionWarning: some View {
        Text("Failed to resolve post. Try another account.")
            .padding(.vertical, 3)
            .frame(maxWidth: .infinity)
            .background(.opacity(0.2), in: .capsule)
            .foregroundStyle(palette.caution)
    }
}
