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
        case replies, mentions, messages
        
        var id: String { rawValue }
    }
    
    @Environment(NavigationLayer.self) var navigation
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    
    @AppStorage("inbox.showRead") var showRead: Bool = true
    
    @State var hasDoneInitialLoad: Bool = false
    @State var loadingState: LoadingState = .idle
    
    @State var isAtTop: Bool = true
    @State var selectedTab: Tab = .replies
    
    @State var replies: [Reply2] = []
    @State var mentions: [Reply2] = []
    @State var messages: [Message2] = []
    
    var body: some View {
        FancyScrollView(isAtTop: $isAtTop) {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                Section {
                    Divider()
                    if loadingState == .loading, replies.isEmpty, mentions.isEmpty {
                        ProgressView()
                            .controlSize(.large)
                            .padding()
                            .tint(palette.secondary)
                    } else {
                        if selectedTab == .messages {
                            if messages.isEmpty {
                                Text("Nothing to see here")
                                    .foregroundStyle(palette.secondary)
                                    .padding()
                            } else {
                                ForEach(messages) { message in
                                    VStack(alignment: .leading, spacing: 0) {
                                        MessageView(message: message)
                                        Divider()
                                    }
                                }
                            }
                        } else {
                            let items = selectedTab == .replies ? replies : mentions
                            if items.isEmpty {
                                Text("Nothing to see here")
                                    .foregroundStyle(palette.secondary)
                                    .padding()
                            } else {
                                ForEach(items) { reply in
                                    VStack(alignment: .leading, spacing: 0) {
                                        ReplyView(reply: reply)
                                        Divider()
                                    }
                                }
                            }
                        }
                    }
                } header: {
                    BubblePicker(Tab.allCases, selected: $selectedTab) { tab in
                        tab.rawValue.capitalized
                    }
                    .background(palette.background.opacity(isAtTop ? 1 : 0))
                    .background(.bar)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarEllipsisMenu {
                Toggle(isOn: $showRead) {
                    Label("Show Read", systemImage: Icons.read)
                }
            }
        }
        .onChange(of: taskId) {
            Task { @MainActor in
                replies.removeAll()
                mentions.removeAll()
                messages.removeAll()
                await loadReplies()
            }
        }
        .refreshable {
            guard loadingState != .loading else { return }
            await loadReplies()
        }
        .onAppear {
            guard !hasDoneInitialLoad else { return }
            hasDoneInitialLoad = true
            Task { @MainActor in
                await loadReplies()
            }
        }
    }
    
    var taskId: Int {
        var hasher = Hasher()
        hasher.combine(appState.firstApi.actorId)
        hasher.combine(showRead)
        return hasher.finalize()
    }
    
    func loadReplies() async {
        loadingState = .loading
        do {
            async let replies = try await appState.firstApi.getReplies(page: 1, limit: 50, unreadOnly: !showRead)
            async let mentions = try await appState.firstApi.getMentions(page: 1, limit: 50, unreadOnly: !showRead)
            async let messages = try await appState.firstApi.getMessages(page: 1, limit: 50, unreadOnly: !showRead)
            self.replies = try await replies
            self.mentions = try await mentions
            self.messages = try await messages
            loadingState = .done
        } catch {
            handleError(error)
            loadingState = .idle
        }
    }
}
