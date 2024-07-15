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
    let proxy: MarkdownTextEditorProxy = .init()
    
    @State var text: String = ""
    @FocusState var focused: Bool
    @State var presentationSelection: PresentationDetent = .large
    var context: ResponseContext
    
    var accountsTracker: AccountsTracker { .main }
    
    var body: some View {
        // Using `.toolbar` to do the keyboard toolbar doesn't work in sheets due to a bug in iOS 17.
        // Using UIKit instead.
        ScrollView {
            MarkdownTextEditor(
                text: $text,
                prompt: "Start writing...",
                proxy: proxy
            ) { keyboardToolbar }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 105, maxHeight: .infinity)
            Divider()
            switch context {
            case let .post(post):
                LargePostBodyView(post: post, isExpanded: true)
                    .padding(.horizontal, AppConstants.standardSpacing)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                accountSwitcher
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Send", systemImage: Icons.send) {}
            }
        }
        .presentationDetents([.medium, .large], selection: $presentationSelection)
    }
    
    @ViewBuilder
    var accountSwitcher: some View {
        Menu {
            Picker(
                "Switch Account",
                selection: Binding<UserAccount?>(
                    get: { appState.firstAccount as? UserAccount },
                    set: { newValue in
                        if let newValue {
                            appState.changeAccount(
                                to: newValue,
                                keepPlace: true,
                                showAvatarPopup: false
                            )
                        }
                    }
                )
            ) {
                ForEach(accountsTracker.userAccounts, id: \.actorId) { account in
                    Button {} label: {
                        Label {
                            Text(account.name)
                        } icon: {
                            SimpleAvatarView(url: account.avatar, type: .person)
                        }
                        Text("@\(account.host ?? "unknown")")
                    }
                    .tag(account as UserAccount?)
                }
            }
            .pickerStyle(.inline)
        } label: {
            // This `Button` wrapper is necessary, otherwise the `Picker` won't work.
            Button(action: {}, label: {
                FullyQualifiedLabelView(
                    entity: appState.firstAccount as? UserAccount, labelStyle: .small,
                    showAvatar: true
                )
            })
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    var keyboardToolbar: some View {
        ScrollView(.horizontal) {
            Spacer()
            HStack(spacing: 16) {
                // iPad already shows these buttons
                if !UIDevice.isPad {
                    keyboardButton("Undo", systemImage: "arrow.uturn.backward") { proxy.undo() }
                    keyboardButton("Redo", systemImage: "arrow.uturn.forward") { proxy.redo() }
                    Divider()
                }
                keyboardButton("Bold", systemImage: "bold") { print("BOLD") }
                keyboardButton("Italic", systemImage: "italic") {}
                keyboardButton("Strikethrough", systemImage: "strikethrough") {}
                keyboardButton("Heading", systemImage: "textformat.size") {}
                keyboardButton("Superscript", systemImage: "textformat.superscript") {}
                keyboardButton("Subscript", systemImage: "textformat.subscript") {}
                keyboardButton("Quote", systemImage: "quote.bubble") {}
                keyboardButton("Image", systemImage: "photo") {}
                keyboardButton("Spoiler", systemImage: "eye") {}
            }
            .padding(.horizontal)
            .padding(.bottom, 2)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity)
        .frame(height: 32)
    }
    
    @ViewBuilder
    func keyboardButton(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label {
                Text(title)
            } icon: {
                Image(systemName: systemImage)
                    .imageScale(.large)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(height: 24)
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        .labelStyle(.iconOnly)
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
