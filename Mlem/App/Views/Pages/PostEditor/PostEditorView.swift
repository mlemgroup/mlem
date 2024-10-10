//
//  PostEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 12/08/2024.
//

import MlemMiddleware
import PhotosUI
import SwiftUI

struct PostEditorView: View {
    enum Field { case title, content }
    enum LinkState: Hashable {
        case none, waiting, value(URL)
        
        var url: URL? {
            switch self {
            case let .value(url): url
            default: nil
            }
        }
    }
    
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    @State var titleTextView: UITextView
    @State var contentTextView: UITextView
    
    @State var postToEdit: Post2?
    @State var presentationSelection: PresentationDetent = .large
    @State var titleIsEmpty: Bool = true
    @State var contentIsEmpty: Bool = true
    @State var lastFocusedField: Field = .title
    @State var hasNsfwTag: Bool = false
    @State var link: LinkState = .none
    @State var imageUrl: URL?
    @State var imageManager: ImageUploadManager?
    @State var uploadHistory: ImageUploadHistoryManager = .init()
    @State var sending: Bool = false
        
    @State var targets: [PostEditorTarget]
    
    init?(
        postToEdit: Post2,
        community: AnyCommunity?
    ) {
        self.init(
            community: community,
            title: postToEdit.title,
            content: postToEdit.content ?? "",
            url: postToEdit.linkUrl,
            nsfw: postToEdit.nsfw
        )
        self.postToEdit = postToEdit
    }
    
    init?(
        community: AnyCommunity?,
        title: String = "",
        content: String = "",
        url: URL? = nil,
        nsfw: Bool = false
    ) {
        if let account = (AppState.main.firstAccount as? UserAccount) {
            self._targets = .init(wrappedValue: [.init(community: community?.wrappedValue, account: account)])
        } else {
            return nil
        }
        self.titleTextView = .init()
        self.contentTextView = .init()
        titleTextView.tag = 0
        titleTextView.backgroundColor = UIColor(Palette.main.background)
        contentTextView.tag = 1
        contentTextView.backgroundColor = UIColor(Palette.main.background)
        
        titleTextView.text = title
        contentTextView.text = content
        self._hasNsfwTag = .init(wrappedValue: nsfw)
        if let url {
            if url.isMedia {
                self._imageUrl = .init(wrappedValue: url)
            } else {
                self._link = .init(wrappedValue: .value(url))
            }
        }
    }
    
    var body: some View {
        CollapsibleSheetView(presentationSelection: $presentationSelection, canDismiss: canDismiss) {
            NavigationStack {
                contentView
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar { toolbar }
                    .background(palette.background)
            }
            .onAppear {
                contentTextView.resignFirstResponder()
                titleTextView.becomeFirstResponder()
            }
        }
        .onChange(of: imageManager?.image) {
            imageUrl = imageManager?.image?.url
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
        .onDisappear {
            if !navigation.isAlive, !sending {
                Task {
                    do {
                        try await imageManager?.image?.delete()
                    } catch {
                        handleError(error)
                    }
                }
                uploadHistory.deleteAll()
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
                        MarkdownEditorToolbarView(
                            showing: .inlineOnly,
                            textView: titleTextView,
                            imageUploadApi: nil
                        )
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
                    if imageManager != nil || imageUrl != nil {
                        imageView
                            .padding(.horizontal, 12)
                            .transition(attachmentTransition)
                    }
                }
                if !(hasNsfwTag || link != .none || imageManager != nil) {
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
                        MarkdownEditorToolbarView(
                            textView: contentTextView,
                            uploadHistory: uploadHistory,
                            imageUploadApi: primaryApi
                        )
                    }
                )
                .frame(
                    maxWidth: .infinity,
                    minHeight: minTextEditorHeight,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .padding(.top, 4)
                .background(palette.background)
            }
            .animation(.snappy(duration: 0.2, extraBounce: 0.1), value: animationHashValue)
        }
    }
}
