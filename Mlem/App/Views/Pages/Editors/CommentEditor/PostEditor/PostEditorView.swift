//
//  PostEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 12/08/2024.
//

import ComponentViews
import Haptics
import MlemMiddleware
import PhotosUI
import SwiftUI

struct PostEditorView: View {
    enum Field { case title, content }
    enum LinkState: Hashable {
        case none, waiting, value(PostLink)
        
        var url: URL? {
            switch self {
            case let .value(link): link.content
            default: nil
            }
        }
    }

    enum DeferredContent {
        case value(String)
        case callback(() async -> String)
    }

    enum ContentTask {
        case waitingToStart(() async -> String)
        case started
        case finished
    }
    
    @Environment(AppState.self) var appState
    @Environment(HapticManager.self) var hapticManager
    @Environment(NavigationLayer.self) var navigation
    @Environment(ToastModel.self) var toastModel
    @Environment(\.dismiss) var dismiss
    
    @State var titleUiTextView: UITextView
    @State var contentUiTextView: UITextView
    
    @State var postToEdit: Post?
    @State var presentationSelection: PresentationDetent = .large
    @State var titleIsEmpty: Bool = true
    @State var contentIsEmpty: Bool = true
    @State var lastFocusedField: Field? = .title
    @State var hasNsfwTag: Bool = false
    @State var link: LinkState = .none
    @State var imageUrl: URL?
    @State var imageManager: ImageUploadManager?
    @State var thumbnailManager: ImageUploadManager = .init()
    @State var uploadHistory: ImageUploadHistoryManager = .init()
    @State var markdownToolbarEditorModel: MarkdownEditorToolbarModel = .init()
    @State var language: Locale.Language?
    @State var sending: Bool = false
        
    @State var targets: [PostEditorTarget]
    
    @State var titleSlurMatches: [String: String] = .init()
    @State var bodySlurMatches: [String: String] = .init()
    @State var titleSlurTask: Task<Void, Never>?
    @State var bodySlurTask: Task<Void, Never>?

    @State var contentTask: ContentTask?
    
    var feedLoader: (any FeedLoading)?
    
    /// Initializer for editing a post
    init?(
        postToEdit: Post,
        community: Community?
    ) {
        self.init(
            community: community,
            title: postToEdit.title,
            content: .value(postToEdit.content ?? ""),
            type: postToEdit.type,
            nsfw: postToEdit.nsfw,
            feedLoader: nil
        )
        self._postToEdit = .init(wrappedValue: postToEdit)
    }
    
    /// Initializer for creating a post
    init?(
        community: Community?,
        title: String = "",
        content: DeferredContent,
        type: PostType? = nil,
        nsfw: Bool = false,
        feedLoader: (any FeedLoading)?
    ) {
        if let account = (AppState.main.firstAccount as? UserAccount) {
            self._targets = .init(wrappedValue: [.init(community: community, account: account)])
        } else {
            return nil
        }
        self.feedLoader = feedLoader
        self.titleUiTextView = .init()
        self.contentUiTextView = .init()
        titleUiTextView.tag = 0
        contentUiTextView.tag = 1
        
        titleUiTextView.text = title

        switch content {
        case let .value(value):
            contentUiTextView.text = value
        case let .callback(callback):
            self._contentTask = .init(wrappedValue: .waitingToStart(callback))
        }

        self._titleIsEmpty = .init(wrappedValue: title.isEmpty)
        self._hasNsfwTag = .init(wrappedValue: nsfw)
        
        switch type {
        case let .media(url):
            self._imageUrl = .init(wrappedValue: url)
        case let .embedded(_, url):
            self._link = .init(wrappedValue: .value(.init(content: url, thumbnail: nil, label: "")))
        case let .link(url):
            self._link = .init(wrappedValue: .value(url))
        case .titleOnly, .text, .poll, nil:
            break
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
                contentUiTextView.resignFirstResponder()
                titleUiTextView.becomeFirstResponder()
            }
        }
        .onAppear {
            targets.first?.onAccountChange = checkSlurFilters
        }
        .onChange(of: primaryApi, initial: true) {
            markdownToolbarEditorModel.imageUploadApi = primaryApi
        }
        .task {
            switch self.contentTask {
            case let .waitingToStart(callback):
                self.contentTask = .started
                self.contentUiTextView.text = await callback()
                self.contentTask = .finished
            default:
                break
            }
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
                titleUiTextView.resignFirstResponder()
                titleUiTextView.isEditable = false
                contentUiTextView.resignFirstResponder()
                contentUiTextView.isEditable = false
            } else {
                titleUiTextView.isEditable = true
                contentUiTextView.isEditable = true
            }
        }
        .onDisappear {
            if !navigation.isAlive, !sending {
                Task {
                    do {
                        try await imageManager?.image?.delete()
                        try await thumbnailManager.image?.delete()
                    } catch {
                        handleError(error, silent: true)
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
                
                VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                    titleTextView
                    
                    if hasNsfwTag {
                        nsfwTagView
                            .padding(.leading, 10)
                            .transition(attachmentTransition)
                    }
                    
                    attachmentPickerView

                    switch self.contentTask {
                    case .finished, nil:
                        contentTextView
                    case .waitingToStart, .started:
                        ProgressView()
                    }
                }
            }
            .padding([.horizontal, .bottom], Constants.main.standardSpacing)
            .animation(.snappy(duration: 0.2, extraBounce: 0.05), value: animationHashValue)
        }
    }
}
