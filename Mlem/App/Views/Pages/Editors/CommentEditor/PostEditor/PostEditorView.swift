//
//  PostEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 12/08/2024.
//

import ComponentViews
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
    @Environment(\.dismiss) var dismiss
    
    @State var titleTextView: UITextView
    @State var contentTextView: UITextView
    
    @State var postToEdit: Post2?
    @State var presentationSelection: PresentationDetent = .large
    @State var titleIsEmpty: Bool = true
    @State var contentIsEmpty: Bool = true
    @State var lastFocusedField: Field? = .title
    @State var hasNsfwTag: Bool = false
    @State var link: LinkState = .none
    @State var imageUrl: URL?
    @State var imageManager: ImageUploadManager?
    @State var uploadHistory: ImageUploadHistoryManager = .init()
    @State var sending: Bool = false
        
    @State var targets: [PostEditorTarget]
    
    @State var titleSlurMatches: [String: String] = .init()
    @State var bodySlurMatches: [String: String] = .init()
    
    var feedLoader: (any FeedLoading)?
    
    /// Initializer for editing a post
    init?(
        postToEdit: Post2,
        community: AnyCommunity?
    ) {
        self.init(
            community: community,
            title: postToEdit.title,
            content: postToEdit.content ?? "",
            url: postToEdit.linkUrl,
            nsfw: postToEdit.nsfw,
            feedLoader: nil
        )
        self.postToEdit = postToEdit
    }
    
    /// Initializer for creating a post
    init?(
        community: AnyCommunity?,
        title: String = "",
        content: String = "",
        url: URL? = nil,
        nsfw: Bool = false,
        feedLoader: (any FeedLoading)?
    ) {
        if let account = (AppState.main.firstAccount as? UserAccount) {
            self._targets = .init(wrappedValue: [.init(community: community?.wrappedValue, account: account)])
        } else {
            return nil
        }
        self.feedLoader = feedLoader
        self.titleTextView = .init()
        self.contentTextView = .init()
        titleTextView.tag = 0
        contentTextView.tag = 1
        
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
                    .background(.themedGroupedBackground)
            }
            .presentationBackground(.themedGroupedBackground)
            .onAppear {
                contentTextView.resignFirstResponder()
                titleTextView.becomeFirstResponder()
            }
        }
        .onAppear {
            targets.first?.onAccountChange = checkSlurFilters
        }
        .onChange(of: imageManager?.image) {
            imageUrl = imageManager?.image?.url
        }
        .onChange(of: presentationSelection) {
            if presentationSelection == .large {
                restoreFocusState()
            } else {
                saveFocusState()
            }
        }
        .onChange(of: navigation.isTopSheet) {
            if navigation.isTopSheet {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: restoreFocusState)
            } else {
                saveFocusState()
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
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                targetSelectionView
                
                if postToEdit == nil {
                    Line()
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .frame(height: 2)
                        .foregroundStyle(.themedPrimary.opacity(0.2))
                        // The line isn't centered properly due to the way that SwiftUI shapes work; this fixes it
                        .padding(.bottom, -1)
                        .padding(.top, 1)
                }
                
                let hasMiddleParts = hasNsfwTag || link != .none || imageManager != nil || imageUrl != nil
                VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                    VStack(spacing: Constants.main.standardSpacing) {
                        MarkdownTextEditor(
                            onChange: {
                                // Avoid unnecessary view update
                                if titleIsEmpty != $0.isEmpty {
                                    titleIsEmpty = $0.isEmpty
                                }
                                checkSlurFilter(text: $0, slurMatches: $titleSlurMatches)
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
                            minHeight: minTitleEditorHeight,
                            maxHeight: .infinity,
                            alignment: .topLeading
                        )
  
                        if !titleSlurMatches.isEmpty {
                            FilterViolationWarning(failures: titleSlurMatches)
                                .padding(.horizontal, Constants.main.standardSpacing)
                                .padding(.bottom, Constants.main.standardSpacing)
                        }
                    }
                    .padding(.top, Constants.main.halfSpacing)
                    .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                    
                    if hasNsfwTag {
                        nsfwTagView
                            .padding(.leading, 10)
                            .transition(attachmentTransition)
                    }

                    HStack(spacing: 10) {
                        if imageManager == nil, imageUrl == nil {
                            linkView
                                .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                        if link == .none {
                            imageView
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    
                    VStack {
                        MarkdownTextEditor(
                            onChange: {
                                // Avoid unnecessary view update
                                if contentIsEmpty != $0.isEmpty {
                                    contentIsEmpty = $0.isEmpty
                                }
                                checkSlurFilter(text: $0, slurMatches: $bodySlurMatches)
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
  
                        if !bodySlurMatches.isEmpty {
                            FilterViolationWarning(failures: bodySlurMatches)
                                .padding(.horizontal, Constants.main.standardSpacing)
                                .padding(.bottom, Constants.main.standardSpacing)
                        }
                    }
                    .padding([.vertical, .bottom], Constants.main.standardSpacing)
                    .background(
                        .themedSecondaryGroupedBackground,
                        in: UnevenRoundedRectangle(cornerRadii: .init(
                            topLeading: Constants.main.standardSpacing,
                            bottomLeading: Constants.main.standardSpacing,
                            bottomTrailing: Constants.main.standardSpacing,
                            topTrailing: Constants.main.standardSpacing
                        ))
                    )
                }
            }
            .padding([.horizontal, .bottom], Constants.main.standardSpacing)
            .animation(.snappy(duration: 0.2, extraBounce: 0.05), value: animationHashValue)
        }
    }
}
