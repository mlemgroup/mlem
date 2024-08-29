//
//  PostComposerView.swift
//  Mlem
//
//  Created by Sjmarf on 12/08/2024.
//

import MlemMiddleware
import SwiftUI

struct PostEditorView: View {
    enum Field { case title, content }
    enum LinkState: Hashable { case none, waiting, value(URL) }
    enum ImageState: Hashable { case none, waiting, value(ImageUpload1) }
    
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    @State var titleTextView: UITextView
    @State var contentTextView: UITextView
    
    @State var presentationSelection: PresentationDetent = .large
    @State var titleIsEmpty: Bool = true
    @State var contentIsEmpty: Bool = true
    @State var lastFocusedField: Field = .title
    @State var hasNsfwTag: Bool = false
    @State var link: LinkState = .none
    @State var image: ImageState = .none
    @State var sending: Bool = false
    
    @State var targets: [PostEditorTarget]
    
    init?(community: AnyCommunity?) {
        if let account = (AppState.main.firstAccount as? UserAccount) {
            self._targets = .init(wrappedValue: [.init(community: community?.wrappedValue, account: account)])
        } else {
            return nil
        }
        self.titleTextView = .init()
        self.contentTextView = .init()
        titleTextView.tag = 0
        contentTextView.tag = 1
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
        .onChange(of: sending) {
            if sending {
                titleTextView.resignFirstResponder()
                titleTextView.isEditable = false
                contentTextView.resignFirstResponder()
                contentTextView.isEditable = false
            } else {
                titleTextView.isEditable = true
                contentTextView.isEditable = true
            }
        }
    }
    
    @ViewBuilder
    var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                targetSelectionView
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
                VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                    if hasNsfwTag {
                        nsfwTagView
                            .padding(.leading, 15)
                            .transition(attachmentTransition)
                    }
                    if link != .none {
                        linkView
                            .padding(.horizontal, 12)
                            .transition(attachmentTransition)
                    }
                    if image != .none {
                        imageView
                            .padding(.horizontal, 12)
                            .transition(attachmentTransition)
                    }
                }
                if !(hasNsfwTag || link != .none || image != .none) {
                    Divider()
                }
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
                .padding(.top, 4)
            }
            .animation(.snappy(duration: 0.2, extraBounce: 0.1), value: animationHashValue)
        }
    }
    
    @ViewBuilder
    var targetSelectionView: some View {
        VStack(spacing: Constants.main.standardSpacing) {
            ForEach(targets, id: \.id) { target in
                HStack(spacing: 0) {
                    PostEditorTargetView(target: target)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if targets.count > 1 {
                        Button("Remove", systemImage: Icons.closeCircleFill) {
                            if let index = targets.firstIndex(where: { $0.id == target.id }) {
                                targets.remove(at: index)
                            }
                        }
                        .symbolRenderingMode(.hierarchical)
                        .imageScale(.large)
                        .labelStyle(.iconOnly)
                        .padding(.trailing)
                    }
                }
                Divider()
            }
            let showWarning = !targets.allSatisfy { $0.sendState != .failed }
            Group {
                if showWarning {
                    Text("One of more of your posts failed to send.")
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 3)
                        .frame(maxWidth: .infinity)
                        .background(.opacity(0.2), in: .capsule)
                        .foregroundStyle(palette.negative)
                        .padding(.horizontal)
                }
            }.animation(.easeOut(duration: 0.2), value: showWarning)
        }
    }
    
    @ViewBuilder
    var nsfwTagView: some View {
        Button {
            hasNsfwTag = false
        } label: {
            HStack {
                Text("NSFW")
                    .font(.footnote)
                    .fontWeight(.black)
                    .foregroundStyle(palette.selectedInteractionBarItem)
                Image(systemName: Icons.close)
                    .foregroundStyle(.opacity(0.8))
            }
            .foregroundStyle(.white)
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .background(palette.warning, in: .capsule)
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
                Toggle(
                    "Link",
                    systemImage: Icons.websiteAddress,
                    isOn: .init(get: { link != .none }, set: { link = $0 ? .waiting : .none })
                ).disabled(image != .none)
                Toggle(
                    "Image",
                    systemImage: Icons.uploadImage,
                    isOn: .init(get: { image != .none }, set: { image = $0 ? .waiting : .none })
                )
                .disabled(link != .none)
                Toggle("NSFW Tag", systemImage: "tag", isOn: $hasNsfwTag)
                Button("Crosspost", systemImage: "shuffle") {
                    if let account = targets.last?.account {
                        targets.append(.init(account: account))
                    }
                }
            }
            if sending {
                ProgressView()
            } else {
                Button("Send", systemImage: Icons.send) {
                    sending = true
                    Task { await send() }
                }
                .disabled(!canSubmit)
            }
        }
    }
}
