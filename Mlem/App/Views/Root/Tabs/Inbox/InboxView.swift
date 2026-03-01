//
//  InboxView.swift
//  Mlem
//
//  Created by Sjmarf on 19/05/2024.
//

import Haptics
import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI
import Theming

struct InboxView: View {
    @Environment(AppState.self) var appState
    @Environment(HapticManager.self) var hapticManager
    @Environment(NavigationLayer.self) var navigation
    @Environment(FiltersTracker.self) var filtersTracker
    @Environment(ToastModel.self) var toastModel
    
    @Setting(\.inbox_showRead) var showRead
    
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
    
    @State var reportFeedLoader: ReportChildFeedLoader
    @State var applicationFeedLoader: ApplicationChildFeedLoader
    @State var modMailFeedLoader: ModMailFeedLoader
    
    @State var showRefreshPopup: Bool = false
    
    init() {
        @Setting(\.behavior_internetSpeed) var internetSpeed
        @Setting(\.inbox_showRead) var showRead
        
        let inboxFeedLoaders = InboxFeedLoader.setup(
            api: AppState.main.firstApi,
            pageSize: internetSpeed.pageSize,
            sortType: .new,
            showRead: showRead
        )
        
        self._replyFeedLoader = .init(wrappedValue: inboxFeedLoaders.replyFeedLoader)
        self._mentionFeedLoader = .init(wrappedValue: inboxFeedLoaders.mentionFeedLoader)
        self._messageFeedLoader = .init(wrappedValue: inboxFeedLoaders.messageFeedLoader)
        self._inboxFeedLoader = .init(wrappedValue: inboxFeedLoaders.inboxFeedLoader)
        
        let modMailFeedLoaders = ModMailFeedLoader.setup(
            api: AppState.main.firstApi,
            pageSize: internetSpeed.pageSize,
            sortType: .new,
            showRead: showRead
        )
        
        self._reportFeedLoader = .init(wrappedValue: modMailFeedLoaders.reportFeedLoader)
        self._applicationFeedLoader = .init(wrappedValue: modMailFeedLoaders.applicationFeedLoader)
        self._modMailFeedLoader = .init(wrappedValue: modMailFeedLoaders.modMailFeedLoader)
    }
    
    var feedLoader: StandardFeedLoader<InboxNotification> {
        if appState.firstApi.supports(.viewMentionsAndPrivateMessages, defaultValue: false) {
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
        } else {
            replyFeedLoader
        }
    }
    
    var currentModFeedLoader: StandardFeedLoader<ModMailItem> {
        switch selectedModTab {
        case .applications: applicationFeedLoader
        case .reports: reportFeedLoader
        }
    }
    
    var availableFeeds: [Feed] {
        if appState.isModOrAdmin, appState.firstApi.supports(.viewReports, defaultValue: false) {
            return [.inbox, .modMail]
        }
        return [.inbox]
    }
    
    var body: some View {
        if appState.firstSession is GuestSession {
            signedOutInfoView
        } else {
            content
                .themedGroupedBackground()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbar }
                .loadFeed(inboxFeedLoader)
                .loadFeed(modMailFeedLoader, shouldLoad: appState.firstApi.supports(.viewReports, defaultValue: false))
                .onChange(of: appState.firstApi, initial: false) {
                    if appState.firstAccount is UserAccount {
                        Task {
                            await inboxFeedLoader.changeApi(to: appState.firstApi, context: filtersTracker.filterContext)
                            await modMailFeedLoader.changeApi(to: appState.firstApi, context: filtersTracker.filterContext)
                        }
                        showRefreshPopup = true
                    }
                }
                .onChange(of: showRead, initial: false) {
                    Task {
                        do {
                            if showRead {
                                try await inboxFeedLoader.showRead()
                                if appState.firstApi.supports(.viewReports, defaultValue: false) {
                                    try await modMailFeedLoader.showRead()
                                }
                            } else {
                                try await inboxFeedLoader.hideRead()
                                if appState.firstApi.supports(.viewReports, defaultValue: false) {
                                    try await modMailFeedLoader.hideRead()
                                }
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
        FancyScrollView(reselectAction: toggleFeed) {
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
                        if UIDevice.isIos26, headerPinned { return }
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
            if selectedFeed == .modMail, !appState.isModOrAdmin {
                selectedFeed = .inbox
            }
            switch selectedFeed {
            case .inbox:
                try await inboxFeedLoader.refresh(clearBeforeRefresh: false)
                if appState.firstApi.supports(.viewReports, defaultValue: false) {
                    Task {
                        try await modMailFeedLoader.refresh(clearBeforeRefresh: false)
                    }
                }
            case .modMail:
                try await modMailFeedLoader.refresh(clearBeforeRefresh: false)
                Task {
                    try await inboxFeedLoader.refresh(clearBeforeRefresh: false)
                }
            }
        } catch {
            handleError(error)
        }
    }
    
    private func toggleFeed() {
        selectedFeed = selectedFeed == .inbox && appState.isModOrAdmin ? .modMail : .inbox
    }
}

private struct ScrollOffsetKey: PreferenceKey {
    typealias Value = Bool
    static var defaultValue = false
    static func reduce(value: inout Value, nextValue: () -> Value) {}
}
