//
//  PostComposerView.swift
//  Mlem
//
//  Created by Sjmarf on 12/08/2024.
//

import MlemMiddleware
import SwiftUI

struct PostComposerView: View {
    enum Field { case title, content }
    
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    let titleTextView: UITextView
    let contentTextView: UITextView
    
    @State var presentationSelection: PresentationDetent = .large
    @State var titleIsEmpty: Bool = true
    @State var contentIsEmpty: Bool = true
    @State var lastFocusedField: Field = .title
    
    @State var targets: [PostComposerTarget]
    
    init?(community: AnyCommunity?) {
        self.titleTextView = .init()
        self.contentTextView = .init()
        titleTextView.tag = 0
        contentTextView.tag = 1
        if let account = (AppState.main.firstAccount as? UserAccount) {
            self._targets = .init(wrappedValue: [.init(community: community?.wrappedValue, account: account)])
        } else {
            return nil
        }
    }
    
    var body: some View {
        CollapsibleSheetView(presentationSelection: $presentationSelection, canDismiss: canDismiss) {
            NavigationStack {
                contentView
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar { toolbar }
            }
            .onAppear {
                titleTextView.becomeFirstResponder()
            }
        }
        .onChange(of: presentationSelection) {
            if presentationSelection == .large {
                switch lastFocusedField {
                case .title:
                    titleTextView.becomeFirstResponder()
                case .content:
                    contentTextView.becomeFirstResponder()
                }
            } else {
                lastFocusedField = contentTextView.isFirstResponder ? .content : .title
            }
        }
    }
    
    var minTextEditorHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .title2).lineHeight * 4 + 15
    }
    
    var canDismiss: Bool { titleIsEmpty && contentIsEmpty }
    
    var canSubmit: Bool {
        !titleIsEmpty && !contentIsEmpty && targets.allSatisfy { $0.community != nil }
    }
    
    @ViewBuilder
    var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(spacing: Constants.main.standardSpacing) {
                    ForEach(targets, id: \.id) { target in
                        PostComposerTargetView(target: target)
                        Divider()
                    }
                }
                .padding(.bottom, 6)
                MarkdownTextEditor(
                    onChange: {
                        // Avoid unnecessary view update
                        if titleIsEmpty != $0.isEmpty {
                            titleIsEmpty = $0.isEmpty
                        }
                    },
                    prompt: "Title",
                    textView: titleTextView,
                    font: .preferredFont(forTextStyle: .title2),
                    content: {
                        MarkdownEditorToolbarView(showing: .inlineOnly, textView: titleTextView)
                    }
                )
                .frame(
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                Divider()
                    .padding(.bottom, 4)
                MarkdownTextEditor(
                    onChange: {
                        // Avoid unnecessary view update
                        if contentIsEmpty != $0.isEmpty {
                            contentIsEmpty = $0.isEmpty
                        }
                    },
                    prompt: "Optional Description",
                    textView: contentTextView,
                    content: {
                        MarkdownEditorToolbarView(textView: contentTextView)
                    }
                )
                .frame(
                    maxWidth: .infinity,
                    minHeight: minTextEditorHeight,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
            }
        }
    }
    
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Cancel") {
                dismiss()
            }
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            Menu("Add", systemImage: "plus") {
                Button("Link", systemImage: Icons.websiteAddress) {}.disabled(true)
                Button("Image", systemImage: Icons.uploadImage) {}.disabled(true)
                Button("NSFW Tag", systemImage: "tag") {}
                Button("Crosspost", systemImage: "shuffle") {
                    if let account = targets.last?.account {
                        targets.append(.init(account: account))
                    }
                }
            }
            Button("Send", systemImage: Icons.send) {}
        }
    }
}
