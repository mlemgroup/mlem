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
        if appState.firstSession is GuestSession {
            signedOutInfoView
        } else {
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
}

private struct ScrollOffsetKey: PreferenceKey {
    typealias Value = Bool
    static var defaultValue = false
    static func reduce(value: inout Value, nextValue: () -> Value) {}
}
