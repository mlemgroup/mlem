//
//  InboxView.swift
//  Mlem
//
//  Created by Sjmarf on 19/05/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct InboxView: View {
    enum Tab: CaseIterable, Identifiable {
        case all, replies, mentions, messages
        
        var id: Tab { self }
        
        var label: LocalizedStringResource {
            switch self {
            case .all: "All"
            case .replies: "Replies"
            case .mentions: "Mentions"
            case .messages: "Messages"
            }
        }
    }
    
    @Environment(NavigationLayer.self) var navigation
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    
    @Setting(\.showReadInInbox) var showRead
    
    @State var hasDoneInitialLoad: Bool = false
    
    @State var headerPinned: Bool = false
    @State var selectedTab: Tab = .all
    
    @State var replyFeedLoader: ReplyFeedLoader
    @State var mentionFeedLoader: MentionFeedLoader
    @State var messageFeedLoader: MessageFeedLoader
    @State var inboxFeedLoader: InboxFeedLoader
    
    @State var showRefreshPopup: Bool = false
    @State var waitingOnMarkAllAsRead: Bool = false
    @State var markAllAsReadTrigger: Bool = false
    
    var loadingState: LoadingState {
        switch selectedTab {
        case .all:
            inboxFeedLoader.loadingState
        case .replies:
            replyFeedLoader.loadingState
        case .mentions:
            mentionFeedLoader.loadingState
        case .messages:
            messageFeedLoader.loadingState
        }
    }
    
    init() {
        @Setting(\.internetSpeed) var internetSpeed
        
        let replyFeedLoader: ReplyFeedLoader = .init(api: AppState.main.firstApi, pageSize: internetSpeed.pageSize, sortType: .new)
        let mentionFeedLoader: MentionFeedLoader = .init(api: AppState.main.firstApi, pageSize: internetSpeed.pageSize, sortType: .new)
        let messageFeedLoader: MessageFeedLoader = .init(api: AppState.main.firstApi, pageSize: internetSpeed.pageSize, sortType: .new)
        
        let inboxFeedLoader: InboxFeedLoader = .init(
            api: AppState.main.firstApi,
            pageSize: internetSpeed.pageSize,
            sources: [replyFeedLoader, mentionFeedLoader, messageFeedLoader],
            sortType: .new
        )
        
        self._replyFeedLoader = .init(wrappedValue: replyFeedLoader)
        self._mentionFeedLoader = .init(wrappedValue: mentionFeedLoader)
        self._messageFeedLoader = .init(wrappedValue: messageFeedLoader)
        self._inboxFeedLoader = .init(wrappedValue: inboxFeedLoader)
    }
    
    var body: some View {
        if appState.firstSession is GuestSession {
            signedOutInfoView
        } else {
            content
                .background(palette.groupedBackground)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbar }
                .loadFeed(inboxFeedLoader)
                .onChange(of: appState.firstApi, initial: false) {
                    if appState.firstAccount is UserAccount {
                        Task {
                            await inboxFeedLoader.changeApi(to: appState.firstApi)
                        }
                        showRefreshPopup = true
                    }
                }
                .onChange(of: showRead, initial: false) {
                    Task {
                        await inboxFeedLoader.add
                    }
                }
                .refreshable {
                    _ = await Task {
                        await refresh()
                    }.result
                }
                .onChange(of: (appState.firstSession as? UserSession)?.unreadCount?.updateId ?? 0) { oldValue, newValue in
                    // The newValue > oldValue check stops the popup from appearing when the user switches accounts.
                    // This is a little janky, but it works
                    if newValue > oldValue, loadingState == .done {
                        showRefreshPopup = true
                    }
                }
                .overlay(alignment: .bottom) {
                    RefreshPopupView("Inbox is outdated", isPresented: $showRefreshPopup) {
                        Task { @MainActor in
                            await refresh()
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    var content: some View {
        FancyScrollView {
            VStack(spacing: 0) {
                FeedHeaderView(
                    feedDescription: .init(
                        label: "Inbox",
                        subtitle: "Replies, mentions and messages",
                        color: { $0.inbox },
                        iconName: Icons.inbox,
                        iconNameFill: Icons.inboxFill,
                        iconScaleFactor: 0.5
                    ),
                    dropdownStyle: .disabled
                )
                GeometryReader { geo in
                    Color.red.preference(
                        key: ScrollOffsetKey.self,
                        value: geo.frame(in: .named("inboxScrollView")).origin.y >= 0
                    )
                }
                .frame(width: 0, height: 0)
                .onPreferenceChange(ScrollOffsetKey.self, perform: { value in
                    if value != headerPinned {
                        headerPinned = value
                    }
                })
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section {
                        Group {
                            switch selectedTab {
                            case .all:
                                allItemsView
                            case .replies:
                                repliesView
                            case .mentions:
                                mentionsView
                            case .messages:
                                messagesView
                            }
                        }
                    } header: { sectionHeader }
                }
            }
        }
        .coordinateSpace(name: "inboxScrollView")
    }
    
    private func refresh() async {
        do {
            try await inboxFeedLoader.refresh(clearBeforeRefresh: true)
        } catch {
            handleError(error)
        }
    }
}

private struct ScrollOffsetKey: PreferenceKey {
    typealias Value = Bool
    static var defaultValue = false
    static func reduce(value: inout Value, nextValue: () -> Value) {}
}
