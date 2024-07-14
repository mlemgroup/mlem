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
    enum Tab: String, CaseIterable, Identifiable {
        case all, replies, mentions, messages
        
        var id: String { rawValue }
    }
    
    @Environment(NavigationLayer.self) var navigation
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    
    @AppStorage("inbox.showRead") var showRead: Bool = true
    
    @State var hasDoneInitialLoad: Bool = false
    @State var loadingState: LoadingState = .idle
    
    @State var headerPinned: Bool = false
    @State var selectedTab: Tab = .all
    
    @State var replies: [Reply2] = []
    @State var mentions: [Reply2] = []
    @State var messages: [Message2] = []
    @State var combined: [any InboxItemProviding] = []
    
    @State var showRefreshPopup: Bool = false
    
    var items: [any InboxItemProviding] {
        switch selectedTab {
        case .all:
            combined
        case .replies:
            replies
        case .mentions:
            mentions
        case .messages:
            messages
        }
    }
    
    var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarEllipsisMenu {
                    Button("Mark All as Read", systemImage: Icons.markRead) {
                        Task {
                            do {
                                try await appState.firstApi.markAllAsRead()
                                if !showRead {
                                    removeAll()
                                }
                            } catch {
                                handleError(error)
                            }
                        }
                    }
                    Toggle(isOn: $showRead.invert()) {
                        Label("Hide Read", systemImage: Icons.read)
                    }
                }
            }
            .onChange(of: taskId) {
                Task { @MainActor in
                    showRefreshPopup = false
                    removeAll()
                    await loadReplies()
                }
            }
            .refreshable {
                _ = await Task {
                    await loadReplies()
                }.result
            }
            .onAppear {
                guard !hasDoneInitialLoad else { return }
                hasDoneInitialLoad = true
                Task { @MainActor in
                    await loadReplies()
                }
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
                        removeAll()
                        await loadReplies()
                    }
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
        FancyScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                FeedHeaderView(
                    feedDescription: .init(
                        label: "Inbox",
                        subtitle: "Replies, mentions and messages",
                        color: \.inbox,
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
                Divider()
                Section {
                    if loadingState == .loading, replies.isEmpty, mentions.isEmpty {
                        ProgressView()
                            .controlSize(.large)
                            .padding()
                            .tint(palette.secondary)
                    } else {
                        if items.isEmpty {
                            Text("Nothing to see here")
                                .foregroundStyle(palette.secondary)
                                .padding()
                        } else {
                            ForEach(items, id: \.id) { item in
                                VStack(alignment: .leading, spacing: 0) {
                                    if let reply = item as? Reply2, !reply.creator.blocked {
                                        ReplyView(reply: reply)
                                    }
                                    if let message = item as? Message2, !message.creator.blocked {
                                        MessageView(message: message)
                                    }
                                    Divider()
                                }
                            }
                        }
                    }
                } header: { sectionHeader }
            }
        }
        .coordinateSpace(name: "inboxScrollView")
    }
    
    @ViewBuilder
    var sectionHeader: some View {
        BubblePicker(
            Tab.allCases,
            selected: $selectedTab,
            withDividers: [.bottom],
            label: { tab in
                tab.rawValue.capitalized
            },
            value: { tab in
                if let unreadCount = (appState.firstSession as? UserSession)?.unreadCount {
                    switch tab {
                    case .all:
                        return unreadCount.total
                    case .replies:
                        return unreadCount.replies
                    case .mentions:
                        return unreadCount.mentions
                    case .messages:
                        return unreadCount.messages
                    }
                }
                return 0
            }
        )
        .background(palette.background.opacity(headerPinned ? 1 : 0))
        .background(.bar)
    }
    
    var taskId: Int {
        var hasher = Hasher()
        hasher.combine(appState.firstApi.actorId)
        hasher.combine(showRead)
        return hasher.finalize()
    }
    
    func removeAll() {
        replies.removeAll()
        mentions.removeAll()
        messages.removeAll()
        combined.removeAll()
    }
    
    func loadReplies() async {
        loadingState = .loading
        do {
            async let replies = appState.firstApi.getReplies(page: 1, limit: 50, unreadOnly: !showRead)
            async let mentions = appState.firstApi.getMentions(page: 1, limit: 50, unreadOnly: !showRead)
            async let messages = appState.firstApi.getMessages(page: 1, limit: 50, unreadOnly: !showRead)
            try await (appState.firstSession as? UserSession)?.unreadCount?.refresh()
            self.replies = try await replies
            self.mentions = try await mentions
            self.messages = try await messages
            combined = (self.replies + self.mentions + self.messages).sorted(by: { $0.created > $1.created })
            loadingState = .done
        } catch {
            handleError(error)
            loadingState = .idle
        }
    }
}

private struct ScrollOffsetKey: PreferenceKey {
    typealias Value = Bool
    static var defaultValue = false
    static func reduce(value: inout Value, nextValue: () -> Value) {}
}
