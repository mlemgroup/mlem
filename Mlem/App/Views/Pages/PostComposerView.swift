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
    
    @State var community: AnyCommunity?
    
    let titleTextView: UITextView
    let contentTextView: UITextView
    
    @State var presentationSelection: PresentationDetent = .large
    @State var titleIsEmpty: Bool = true
    @State var contentIsEmpty: Bool = true
    @State var lastFocusedField: Field = .title
    
    @State var account: UserAccount
    
    init?(community: AnyCommunity?) {
        self._community = .init(wrappedValue: community)
        self.titleTextView = .init()
        self.contentTextView = .init()
        titleTextView.tag = 0
        contentTextView.tag = 1
        if let userAccount = (AppState.main.firstAccount as? UserAccount) {
            self._account = .init(wrappedValue: userAccount)
        } else {
            return nil
        }
    }
    
    var body: some View {
        CollapsibleSheetView(presentationSelection: $presentationSelection, canDismiss: canDismiss) {
            NavigationStack {
                contentView
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") {
                                dismiss()
                            }
                        }
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            Menu("Add", systemImage: "plus") {
                                Button("Link", systemImage: Icons.websiteAddress) {}
                                Button("Image", systemImage: Icons.uploadImage) {}
                                Button("NSFW Tag", systemImage: "tag") {}
                                Button("Crosspost", systemImage: "shuffle") {}
                            }
                            Button("Send", systemImage: Icons.send) {}
                        }
                    }
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
    
    @ViewBuilder
    var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                targetInfo
                    .padding(.bottom, 10)
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
    
    @ViewBuilder
    var targetInfo: some View {
        HStack {
            if let community = community?.wrappedValue as? any Community {
                Button {
                    navigation.openSheet(.communityPicker(callback: { self.community = .init($0) }))
                } label: {
                    Group {
                        // Hide community instance if the line is too long.
                        ViewThatFits {
                            FullyQualifiedLabelView(
                                entity: community,
                                labelStyle: .small,
                                showInstance: true
                            )
                            FullyQualifiedLabelView(
                                entity: community,
                                labelStyle: .small,
                                showInstance: false
                            )
                        }
                    }
                    .padding(.init(top: 2, leading: 4, bottom: 2, trailing: 8))
                    .background(palette.secondaryBackground, in: .capsule)
                }
            }
            AccountPickerMenu(account: $account) {
                FullyQualifiedLabelView(
                    entity: account,
                    labelStyle: .small
                )
                .padding(.init(top: 2, leading: 4, bottom: 2, trailing: 8))
                .background(palette.secondaryBackground, in: .capsule)
            }
        }
        .font(.caption)
        .padding(.horizontal, 10)
    }
}
