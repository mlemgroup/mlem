//
//  MessageFeedView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-22.
//

import ComponentViews
import Icons
import MlemMiddleware
import SwiftUI
import Theming

// swiftlint:disable:next type_body_length
struct MessageFeedView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.dismiss) var dismiss
    
    let person: AnyPerson
    let focusTextField: Bool
    @State var editing: (any Message)?
    @State var textViewWasFirstResponder: Bool = false
    
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    @State var markdownToolbarEditorModel: MarkdownEditorToolbarModel = .init()

    init(
        person: AnyPerson,
        messageContent: String = "",
        focusTextField: Bool,
        editing: (any Message)?
    ) {
        self.person = person
        self.focusTextField = focusTextField
        self._editing = .init(wrappedValue: editing)
        let textView = UITextView()
        textView.text = editing?.content ?? messageContent
        _textView = .init(wrappedValue: textView)
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
                            ToolbarItem(placement: .principal) { navigationTitleView(person: person) }
                            ToolbarItemGroup(placement: .secondaryAction) {
                                SwiftUI.Section {
                                    if person is any Person3Providing, proxy.isLoading {
                                        ProgressView()
                                    } else {
                                        MenuButtons {
                                            person.menuActions(
                                                appState: appState,
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
                    .popupAnchor()
                    .onChange(of: navigation.isTopSheet) {
                        if navigation.isTopSheet, navigation.model != nil {
                            textView.becomeFirstResponder()
                        }
                    }
            }
        }
    }
    
    @ViewBuilder func content(person: any Person) -> some View {
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
                    .onChange(of: feedLoader.items.isEmpty) {
                        for message in feedLoader.items {
                            message.updateRead(true)
                        }
                    }
                    .onReceive(timer) { _ in
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
            .safeAreaInset(edge: .bottom) { textInput(scrollProxy) }
            .defaultScrollAnchor(.bottom)
            .scrollDismissesKeyboard(.interactively)
            .themedGroupedBackground()
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
                .foregroundStyle(.themedSecondary)
                .padding(.bottom, Constants.main.halfSpacing)
        }
        VStack(alignment: message.isOwnMessage ? .trailing : .leading, spacing: Constants.main.halfSpacing) {
            MessageBubbleView(message: message, editCallback: {
                editing = message
                textView.text = message.content
                textView.becomeFirstResponder()
            }, onSelectTextCallback: {
                textViewWasFirstResponder = textView.isFirstResponder
                textView.resignFirstResponder()
            })
            .padding(message.isOwnMessage ? .leading : .trailing, 50)
            .frame(maxWidth: 400, alignment: message.isOwnMessage ? .trailing : .leading)
            .onAppear {
                do {
                    try feedLoader.loadIfThreshold(message)
                } catch {
                    handleError(error)
                }
            }
            .onChange(of: navigation.model?.layers.count) {
                if textViewWasFirstResponder, navigation.model?.layers.count == 0 {
                    textViewWasFirstResponder = false
                    textView.becomeFirstResponder()
                }
            }
            if let footerText = messageFooterText(for: message) {
                Text(footerText)
                    .font(.footnote)
                    .foregroundStyle(.themedSecondary)
                    .padding(.horizontal, Constants.main.halfSpacing)
            }
        }
        .padding([.horizontal, .bottom], Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    func textInput(_ scrollProxy: ScrollViewProxy) -> some View {
        OptimalHeightLayout {
            HStack(alignment: .bottom) {
                ScrollView { textInputView(scrollProxy) }
                    .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                    .scrollIndicators(.hidden)
                HStack(spacing: 6) {
                    if editing != nil {
                        cancelEditButton()
                    }
                    sendButton(scrollProxy)
                }
                .frame(height: minTextEditorHeight - 12)
                .padding(6)
                .fontWeight(.semibold)
            }
            .frame(minHeight: minTextEditorHeight, maxHeight: 200)
        }
        .background(
            RoundedRectangle(cornerRadius: Constants.main.doubleSpacing)
                .strokeBorder(.themedTertiary.opacity(0.5), lineWidth: 1)
        )
        .padding(Constants.main.standardSpacing)
        .background(.bar)
    }
    
    @ViewBuilder
    func cancelEditButton() -> some View {
        Button {
            editing = nil
            textView.text = ""
            textView.resignFirstResponder()
        } label: {
            textInputButtonLabel(icon: .general.close)
        }
        .tint(.themedTertiary)
    }
    
    @ViewBuilder
    func sendButton(_ scrollProxy: ScrollViewProxy) -> some View {
        Button {
            Task { @MainActor in
                if let editing {
                    await editMessage(editing)
                } else {
                    await sendMessage(scrollProxy)
                }
            }
        } label: {
            textInputButtonLabel(icon: editing == nil ? .lemmy.sendMessage : .general.success)
        }
        .tint(.themedAccent)
    }
    
    @ViewBuilder
    func textInputButtonLabel(icon: Icon) -> some View {
        Image(icon: icon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxHeight: .infinity)
            .foregroundStyle(.themedContrastingLabel, .tint)
            .symbolVariant(.circle.fill)
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
            firstResponder: focusTextField && !shouldDelayBecomeFirstResponder,
            sizingOffset: 5,
            content: {
                MarkdownEditorToolbarView(
                    textView: textView,
                    uploadHistory: uploadHistory,
                    model: markdownToolbarEditorModel
                )
            }
        )
        .onChange(of: appState.firstApi) {
            markdownToolbarEditorModel.imageUploadApi = appState.firstApi
        }
        .frame(
            maxWidth: .infinity,
            minHeight: minTextEditorHeight
        )
        .onAppear {
            if focusTextField, shouldDelayBecomeFirstResponder {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    textView.becomeFirstResponder()
                }
            }
        }
    }
    
    @ViewBuilder
    func navigationTitleView(person: any Person) -> some View {
        NavigationLink(.person(person)) {
            HStack(spacing: Constants.main.halfSpacing) {
                CircleCroppedImageView(person, frame: 24)
                Text(person.displayName)
                    .foregroundStyle(.themedPrimary)
                    .font(.headline)
                Image(icon: .general.forward)
                    .imageScale(.small)
                    .fontWeight(.semibold)
                    .foregroundStyle(.themedTertiary)
            }
        }
    }
}
