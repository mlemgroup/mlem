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
    
    let textView: UITextView = .init()
    
    @State var text: String = ""
    @FocusState var focused: Bool
    var context: ResponseContext
    
    @State var account: UserAccount
    @State var presentationSelection: PresentationDetent = .large
    
    init?(
        context: ResponseContext
    ) {
        self.context = context
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
                            Button("Send", systemImage: Icons.send) {}
                        }
                    }
            }
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
            VStack(spacing: 0) {
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
                    .padding(.vertical, Constants.main.standardSpacing)
                switch context {
                case let .post(post):
                    LargePostBodyView(post: post, isExpanded: true)
                        .padding(.horizontal, Constants.main.standardSpacing)
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
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
