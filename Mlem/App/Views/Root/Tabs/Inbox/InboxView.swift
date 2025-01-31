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
    @Environment(FiltersTracker.self) var filtersTracker
    
    @Setting(\.showReadInInbox) var showRead
    
    @State var headerPinned: Bool = false
    @State var selectedFeed: Feed = .inbox
    @State var selectedTab: Tab = .all
    @State var selectedModTab: ModTab = .reports
    
    @State var applications: [RegistrationApplication]?
    @State var reports: [Report]?
    
    @State var replyFeedLoader: ReplyChildFeedLoader
    @State var mentionFeedLoader: MentionChildFeedLoader
    @State var messageFeedLoader: MessageChildFeedLoader
    @State var inboxFeedLoader: InboxFeedLoader
    
    @State var postReportFeedLoader: PostReportChildFeedLoader
    @State var commentReportFeedLoader: CommentReportChildFeedLoader
    @State var messageReportFeedLoader: MessageReportChildFeedLoader
    @State var applicationFeedLoader: ApplicationChildFeedLoader
    @State var modMailFeedLoader: ModMailFeedLoader
    
    @State var showRefreshPopup: Bool = false
    @State var waitingOnMarkAllAsRead: Bool = false
    @State var markAllAsReadTrigger: Bool = false
    
    // swiftlint:disable:next function_body_length
    init() {
        @Setting(\.internetSpeed) var internetSpeed
        @Setting(\.showReadInInbox) var showRead
        
        let replyFeedLoader: ReplyChildFeedLoader = .init(
            api: AppState.main.firstApi,
            pageSize: internetSpeed.pageSize,
            sortType: .new,
            showRead: showRead
        )
        let mentionFeedLoader: MentionChildFeedLoader = .init(
            api: AppState.main.firstApi,
            pageSize: internetSpeed.pageSize,
            sortType: .new,
            showRead: showRead
        )
        let messageFeedLoader: MessageChildFeedLoader = .init(
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
        
        let postReportFeedLoader: PostReportChildFeedLoader = .init(
            api: AppState.main.firstApi,
            pageSize: internetSpeed.pageSize,
            sortType: .new,
            showRead: showRead
        )
        let commentReportFeedLoader: CommentReportChildFeedLoader = .init(
            api: AppState.main.firstApi,
            pageSize: internetSpeed.pageSize,
            sortType: .new,
            showRead: showRead
        )
        let messageReportFeedLoader: MessageReportChildFeedLoader = .init(
            api: AppState.main.firstApi,
            pageSize: internetSpeed.pageSize,
            sortType: .new,
            showRead: showRead
        )
        let applicationFeedLoader: ApplicationChildFeedLoader = .init(
            api: AppState.main.firstApi,
            pageSize: internetSpeed.pageSize,
            sortType: .new,
            showRead: showRead
        )
        
        let modMailFeedLoader: ModMailFeedLoader = .init(
            api: AppState.main.firstApi,
            pageSize: internetSpeed.pageSize,
            sources: [postReportFeedLoader, commentReportFeedLoader, messageReportFeedLoader, applicationFeedLoader],
            sortType: .new,
            showRead: showRead
        )
        
        self._postReportFeedLoader = .init(wrappedValue: postReportFeedLoader)
        self._commentReportFeedLoader = .init(initialValue: commentReportFeedLoader)
        self._messageReportFeedLoader = .init(wrappedValue: messageReportFeedLoader)
        self._applicationFeedLoader = .init(wrappedValue: applicationFeedLoader)
        self._modMailFeedLoader = .init(wrappedValue: modMailFeedLoader)
    }
    
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
    
    var currentModFeedLoader: StandardFeedLoader<ModMailItem> {
        switch selectedModTab {
        case .applications: applicationFeedLoader
        case .reports: postReportFeedLoader
        }
    }
    
    var availableFeeds: [Feed] {
        if appState.firstApi.isAdmin || !(appState.firstPerson?.moderatedCommunities.isEmpty ?? true) {
            return [.inbox, .modMail]
        }
        return [.inbox]
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
                .loadFeed(modMailFeedLoader)
                .onChange(of: appState.firstApi, initial: false) {
                    if appState.firstAccount is UserAccount {
                        Task {
                            await inboxFeedLoader.changeApi(to: appState.firstApi, context: filtersTracker.filterContext)
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
                .onChange(of: (appState.firstSession as? UserSession)?.unreadCount?.refreshNumber ?? 0) { oldValue, newValue in
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
