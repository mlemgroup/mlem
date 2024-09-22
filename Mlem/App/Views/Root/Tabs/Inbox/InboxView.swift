//
//  InboxView.swift
//  Mlem
//
//  Created by Sjmarf on 19/05/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SDWebImageSwiftUI
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
    @State var loadingState: LoadingState = .idle
    
    @State var headerPinned: Bool = false
    @State var selectedTab: Tab = .all
    
    @State var replies: [Reply2] = []
    @State var mentions: [Reply2] = []
    @State var messages: [Message2] = []
    @State var combined: [any InboxItemProviding] = []
    
    @State var showRefreshPopup: Bool = false
    @State var waitingOnMarkAllAsRead: Bool = false
    @State var markAllAsReadTrigger: Bool = false
    
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
            .background(palette.groupedBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbar }
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
                                    Group {
                                        if let reply = item as? Reply2, !reply.creator.blocked {
                                            ReplyView(reply: reply)
                                        }
                                        if let message = item as? Message2, !message.creator.blocked {
                                            MessageView(message: message)
                                        }
                                    }
                                    .padding([.horizontal, .bottom], Constants.main.standardSpacing)
                                }
                            }
                        }
                    } header: { sectionHeader }
                }
            }
        }
        .coordinateSpace(name: "inboxScrollView")
    }
    
    @ViewBuilder
    var sectionHeader: some View {
        BubblePicker(
            Tab.allCases,
            selected: $selectedTab,
            label: \.label,
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
        .background(palette.groupedBackground.opacity(headerPinned ? 1 : 0))
        .background(.bar)
    }
    
    @ViewBuilder
    var refreshPopup: some View {
        HStack(spacing: 0) {
            Text("Inbox is outdated")
                .padding(.horizontal, 10)
            Button {
                showRefreshPopup = false
                HapticManager.main.play(haptic: .lightSuccess, priority: .high)
                Task { @MainActor in
                    removeAll()
                    await loadReplies()
                }
            } label: {
                Label("Refresh", systemImage: Icons.refresh)
                    .foregroundStyle(palette.selectedInteractionBarItem)
                    .fontWeight(.semibold)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(palette.accent, in: .capsule)
            }
            .buttonStyle(.plain)
        }
        .padding(4)
        .background(palette.secondaryBackground, in: .capsule)
        .shadow(color: .black.opacity(0.1), radius: 5)
        .shadow(color: .black.opacity(0.1), radius: 1)
        .padding()
    }
    
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showRead.toggle()
            } label: {
                Label("Hide Read", systemImage: Icons.filter)
                    .symbolVariant(showRead ? .none : .fill)
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            markAllAsReadButton
        }
    }
    
    @ViewBuilder
    var markAllAsReadButton: some View {
        let newMessagesExist = !waitingOnMarkAllAsRead && ((appState.firstSession as? UserSession)?.unreadCount?.total ?? 0) != 0
        PhaseAnimator([0, 1], trigger: markAllAsReadTrigger) { value in
            Button {
                HapticManager.main.play(haptic: .gentleInfo, priority: .low)
                waitingOnMarkAllAsRead = true
                markAllAsReadTrigger.toggle()
                Task {
                    do {
                        try await appState.firstApi.markAllAsRead()
                        if !showRead {
                            removeAll()
                        }
                        try await Task.sleep(for: .seconds(0.05))
                    } catch {
                        handleError(error)
                    }
                    waitingOnMarkAllAsRead = false
                }
            } label: {
                HStack {
                    Image(systemName: Icons.markRead)
                        .imageScale(.small)
                    Text("All")
                }
                .opacity((value == 0 && newMessagesExist) ? 1 : 0)
                .overlay {
                    if value != 0 {
                        Image(systemName: Icons.success)
                            .imageScale(.small)
                            .fontWeight(.semibold)
                    }
                }
                .fixedSize()
                .padding(.vertical, 2)
                .padding(.horizontal, 10)
                .background(.bar, in: .capsule)
            }
            .opacity((newMessagesExist || value != 0) ? 1 : 0)
        }
    }
}

private struct ScrollOffsetKey: PreferenceKey {
    typealias Value = Bool
    static var defaultValue = false
    static func reduce(value: inout Value, nextValue: () -> Value) {}
}
