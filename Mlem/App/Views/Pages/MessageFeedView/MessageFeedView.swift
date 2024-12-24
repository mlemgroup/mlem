//
//  MessageFeedView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-22.
//

import MlemMiddleware
import SwiftUI

struct MessageFeedView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    let person: AnyPerson
    let focusTextField: Bool
    
    init(person: AnyPerson, focusTextField: Bool) {
        self.person = person
        self.focusTextField = focusTextField
    }
    
    @State var feedLoader: MessageFeedLoader?
    @State var textView: UITextView = .init()
    
    @State var uploadHistory: ImageUploadHistoryManager = .init()
        
    var body: some View {
        ContentLoader(model: person) { proxy in
            if let person = proxy.entity {
                content(person: person)
                    .navigationTitle(person.displayName)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        if navigation.isInsideSheet {
                            ToolbarItem(placement: .topBarTrailing) {
                                CloseButtonView()
                            }
                        } else {
                            ToolbarItem(placement: .principal) {
                                NavigationLink(.person(person)) {
                                    HStack(spacing: Constants.main.halfSpacing) {
                                        CircleCroppedImageView(person, frame: 24)
                                        Text(person.displayName)
                                            .foregroundStyle(palette.primary)
                                            .font(.headline)
                                        Image(systemName: Icons.forward)
                                            .imageScale(.small)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(palette.tertiary)
                                    }
                                }
                            }
                            ToolbarItemGroup(placement: .secondaryAction) {
                                SwiftUI.Section {
                                    if person is any Person3Providing, proxy.isLoading {
                                        ProgressView()
                                    } else {
                                        MenuButtons {
                                            person.menuActions(
                                                isInMessageFeed: true,
                                                navigation: navigation,
                                                community: nil
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
            }
        }
    }
    
    @ViewBuilder
    func content(person: any Person) -> some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                if let feedLoader {
                    LazyVStack(spacing: 0) {
                        ForEach(feedLoader.items.reversed()) { message in
                            if !message.deleted {
                                bubbleView(message: message, feedLoader: feedLoader)
                                    .id(message.id)
                            }
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.top, 50)
                    .onChange(of: (appState.firstSession as? UserSession)?.unreadCount?.messages) {
                        Task { @MainActor in
                            do {
                                try await feedLoader.refresh(clearBeforeRefresh: false)
                            } catch {
                                handleError(error)
                            }
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                textInput(scrollProxy)
            }
            .defaultScrollAnchor(.bottom)
            .scrollDismissesKeyboard(.interactively)
            .background(palette.groupedBackground)
            .onAppear {
                if feedLoader == nil {
                    feedLoader = .init(person: person, pageSize: 50)
                    Task { @MainActor in
                        do {
                            try await feedLoader?.loadMoreItems()
                        } catch {
                            handleError(error)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func bubbleView(message: Message2, feedLoader: MessageFeedLoader) -> some View {
        if messageIsFirstOfDay(message) {
            Text(message.created.messagesRelativeDate())
                .font(.footnote)
                .foregroundStyle(palette.secondary)
                .padding(.bottom, Constants.main.halfSpacing)
        }
        VStack(alignment: message.isOwnMessage ? .trailing : .leading, spacing: Constants.main.halfSpacing) {
            MessageBubbleView(message: message)
                .padding(message.isOwnMessage ? .leading : .trailing, 50)
                .frame(maxWidth: 400, alignment: message.isOwnMessage ? .trailing : .leading)
                .onAppear {
                    do {
                        try feedLoader.loadIfThreshold(message)
                    } catch {
                        handleError(error)
                    }
                    message.updateRead(true)
                }
            if message === feedLoader.items.first, Calendar.current.isDateInToday(message.created) {
                Text(message.created.formatted(date: .omitted, time: .shortened))
                    .font(.footnote)
                    .foregroundStyle(palette.secondary)
                    .padding(.horizontal, Constants.main.halfSpacing)
            }
        }
        .padding([.horizontal, .bottom], Constants.main.standardSpacing)
    }
    
    var minTextEditorHeight: CGFloat {
        Constants.main.standardSpacing * 2 + UIFont.preferredFont(forTextStyle: .body).lineHeight
    }
    
    @ViewBuilder
    func textInput(_ scrollProxy: ScrollViewProxy) -> some View {
        OptimalHeightLayout {
            HStack(alignment: .bottom) {
                ScrollView { textInputView(scrollProxy) }
                    .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                    .scrollIndicators(.hidden)
                Button {
                    Task { @MainActor in
                        await sendMessage(scrollProxy)
                    }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: minTextEditorHeight - 12)
                        .fontWeight(.semibold)
                        .foregroundStyle(palette.selectedInteractionBarItem, palette.accent)
                }
                .padding(6)
            }
            .frame(minHeight: minTextEditorHeight, maxHeight: 200)
        }
        .background(
            RoundedRectangle(cornerRadius: Constants.main.doubleSpacing)
                .strokeBorder(palette.tertiary.opacity(0.5), lineWidth: 1)
        )
        .padding(Constants.main.standardSpacing)
        .background(.bar)
    }
    
    @ViewBuilder
    func textInputView(_ scrollProxy: ScrollViewProxy) -> some View {
        MarkdownTextEditor(
            onBeginEditing: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        scrollProxy.scrollTo(feedLoader?.items.first?.id)
                    }
                }
            },
            prompt: "Send a Message...",
            textView: textView,
            insets: .init(
                top: Constants.main.standardSpacing,
                left: Constants.main.standardSpacing,
                bottom: Constants.main.standardSpacing,
                right: Constants.main.standardSpacing
            ),
            firstResponder: focusTextField,
            sizingOffset: 5,
            content: {
                MarkdownEditorToolbarView(
                    textView: textView,
                    uploadHistory: uploadHistory,
                    imageUploadApi: appState.firstApi
                )
            }
        )
        .frame(
            maxWidth: .infinity,
            minHeight: minTextEditorHeight
        )
    }
    
    func messageIsFirstOfDay(_ message: Message2) -> Bool {
        guard let feedLoader else { return false }
        guard let index = feedLoader.items.firstIndex(of: message) else {
            assertionFailure()
            return false
        }
        guard index < feedLoader.items.count - 1 else { return true }
        let previousMessage = feedLoader.items[index + 1]
        return !Calendar.current.isDate(previousMessage.created, inSameDayAs: message.created)
    }
}
