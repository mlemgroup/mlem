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
    
    @State var isAtTop: Bool = true
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
            .onChange(of: (appState.firstSession as? UserSession)?.unreadCount?.updateId) {
                if loadingState == .done {
                    showRefreshPopup = true
                }
            }
            .overlay(alignment: .bottom) {
                Group {
                    if showRefreshPopup {
                        refreshPopup
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.bouncy, value: showRefreshPopup)
            }
    }
    
    @ViewBuilder
    var content: some View {
        FancyScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                Section {
                    Divider()
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
                                    if let reply = item as? Reply2 {
                                        ReplyView(reply: reply)
                                    }
                                    if let message = item as? Message2 {
                                        MessageView(message: message)
                                    }
                                    Divider()
                                }
                            }
                        }
                    }
                } header: {
                    BubblePicker(
                        Tab.allCases,
                        selected: $selectedTab,
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
                    .background(palette.background.opacity(isAtTop ? 1 : 0))
                    .background(.bar)
                }
            }
        }
        .onPreferenceChange(IsAtTopPreferenceKey.self, perform: { value in
            isAtTop = value
        })
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
