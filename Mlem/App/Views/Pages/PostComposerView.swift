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
    
    @State var community: (any CommunityStubProviding)?
    
    let titleTextView: UITextView
    let contentTextView: UITextView
    
    @State var presentationSelection: PresentationDetent = .large
    @State var titleIsEmpty: Bool = true
    @State var contentIsEmpty: Bool = true
    @State var lastFocusedField: Field = .title
    
    @State var account: UserAccount
    
    init?(community: AnyCommunity?) {
        self._community = .init(wrappedValue: community?.wrappedValue)
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
    
    var canSubmit: Bool { !titleIsEmpty && !contentIsEmpty && community != nil }
    
    @ViewBuilder
    var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                targetInfo
                    .padding(.bottom, 10)
                Divider()
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
    
    @ViewBuilder
    var targetInfo: some View {
        Grid(
            alignment: .center,
            horizontalSpacing: 8,
            verticalSpacing: 8
        ) {
            GridRow {
                Image(systemName: Icons.communityFill)
                    .foregroundStyle(palette.secondary)
                    .fontWeight(.semibold)
                communityPicker
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if AccountsTracker.main.userAccounts.count > 1 {
                GridRow {
                    Image(systemName: Icons.personFill)
                        .foregroundStyle(palette.secondary)
                        .fontWeight(.semibold)
                    AccountPickerMenu(account: $account) {
                        FullyQualifiedLabelView(
                            entity: account,
                            labelStyle: .small
                        )
                        .padding(.init(top: 2, leading: 4, bottom: 2, trailing: 8))
                        .background(palette.secondaryBackground, in: .capsule)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .font(.footnote)
        .padding(.leading, 15)
    }
    
    @ViewBuilder
    var communityPicker: some View {
        Button {
            navigation.openSheet(.communityPicker(callback: { community = .init($0) }))
        } label: {
            if let community = community as? any Community {
                FullyQualifiedLabelView(
                    entity: community,
                    labelStyle: .small
                )
                .padding(.init(top: 2, leading: 4, bottom: 2, trailing: 8))
                .background(palette.secondaryBackground, in: .capsule)
            } else if let community {
                FullyQualifiedNameView(name: community.name, instance: community.host, instanceLocation: .trailing)
                    .task {
                        do {
                            self.community = try await community.upgrade()
                        } catch {
                            handleError(error)
                        }
                    }
            } else {
                Text("Choose a community...")
                    .padding(.vertical, 2)
                    .padding(.horizontal, 8)
                    .background(palette.secondaryBackground, in: .capsule)
            }
        }
    }
}
