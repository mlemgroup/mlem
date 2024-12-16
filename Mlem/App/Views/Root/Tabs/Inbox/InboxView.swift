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
    @Environment(NavigationLayer.self) var navigation
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    
    @Setting(\.showReadInInbox) var showRead
    
    @State var headerPinned: Bool = false
    @State var selectedFeed: Feed = .inbox
    @State var selectedTab: Tab = .all
    
    @State var reports: [Report]?
    
    @State var replyFeedLoader: ReplyFeedLoader
    @State var mentionFeedLoader: MentionFeedLoader
    @State var messageFeedLoader: MessageFeedLoader
    @State var inboxFeedLoader: InboxFeedLoader
    
    @State var showRefreshPopup: Bool = false
    @State var waitingOnMarkAllAsRead: Bool = false
    @State var markAllAsReadTrigger: Bool = false
    
    var feedLoader: StandardFeedLoader<InboxItem> {
        switch selectedTab {
        case .all:
            inboxFeedLoader
        case .replies:
            replyFeedLoader
        case .mentions:
            mentionFeedLoader
        case .messages:
            messageFeedLoader
        }
    }
    
    init() {
        @Setting(\.internetSpeed) var internetSpeed
        @Setting(\.showReadInInbox) var showRead
        
        let replyFeedLoader: ReplyFeedLoader = .init(
            api: AppState.main.firstApi,
            pageSize: internetSpeed.pageSize,
            sortType: .new,
            showRead: showRead
        )
        let mentionFeedLoader: MentionFeedLoader = .init(
            api: AppState.main.firstApi,
            pageSize: internetSpeed.pageSize,
            sortType: .new,
            showRead: showRead
        )
        let messageFeedLoader: MessageFeedLoader = .init(
            api: AppState.main.firstApi,
            pageSize: internetSpeed.pageSize,
            sortType: .new,
            showRead: showRead
        )
        
        let inboxFeedLoader: InboxFeedLoader = .init(
            api: AppState.main.firstApi,
            pageSize: internetSpeed.pageSize,
            sources: [replyFeedLoader, mentionFeedLoader, messageFeedLoader],
            sortType: .new,
            showRead: showRead
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
                        do {
                            if showRead {
                                try await inboxFeedLoader.showRead()
                            } else {
                                try await inboxFeedLoader.hideRead()
                            }
                        } catch {
                            handleError(error)
                        }
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
                    if newValue > oldValue, feedLoader.loadingState != .loading {
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
                headerView
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
                switch selectedFeed {
                case .inbox:
                    inboxFeedView
                case .modMail:
                    modMailFeedView
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
