//
//  Inbox View.swift
//  Mlem
//
//  Created by Jake Shirley on 6/25/23.
//

import Dependencies
import Foundation
import SwiftUI

enum InboxFeed: FeedType {
    case inbox
    
    var label: String {
        switch self {
        case .inbox: "Inbox"
        }
    }
        
    var subtitle: String {
        switch self {
        case .inbox: "Replies, mentions, and messages"
        }
    }
    
    var color: Color? {
        switch self {
        case .inbox: .purple
        }
    }
    
    var iconNameFill: String {
        switch self {
        case .inbox: Icons.inboxFill
        }
    }
    
    var iconScaleFactor: CGFloat {
        switch self {
        case .inbox: 0.55
        }
    }
}

enum InboxTab: String, CaseIterable, Identifiable {
    case all, replies, mentions, messages
    
    var id: Self { self }
    
    var label: String {
        rawValue.capitalized
    }
}

struct InboxView: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.commentRepository) var commentRepository
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.notifier) var notifier
    @Dependency(\.personRepository) var personRepository
    
    // MARK: Global
    
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    
    @Environment(\.scrollViewProxy) var scrollProxy
    @Environment(\.navigationPathWithRoutes) private var navigationPath

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var unreadTracker: UnreadTracker

    @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
    
    // MARK: Internal
    
    // error  handling
    @State var errorOccurred: Bool = false
    @State var errorMessage: String = ""
    
    // loading handling
    @State var isLoading: Bool = true
    @AppStorage("shouldFilterRead") var shouldFilterRead: Bool = false
    
    // item feeds
    @StateObject var inboxTracker: InboxTracker
    @StateObject var replyTracker: ReplyTracker
    @StateObject var mentionTracker: MentionTracker
    @StateObject var messageTracker: MessageTracker
    
    init() {
        // TODO: once the post tracker is changed we won't need this here...
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("shouldFilterRead") var unreadOnly = false
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        
        let newReplyTracker = ReplyTracker(internetSpeed: internetSpeed, sortType: .published, unreadOnly: unreadOnly)
        let newMentionTracker = MentionTracker(internetSpeed: internetSpeed, sortType: .published, unreadOnly: unreadOnly)
        let newMessageTracker = MessageTracker(internetSpeed: internetSpeed, sortType: .published, unreadOnly: unreadOnly)
        
        let newInboxTracker = InboxTracker(
            internetSpeed: internetSpeed,
            sortType: .published,
            childTrackers: [
                newReplyTracker,
                newMentionTracker,
                newMessageTracker
            ]
        )
        
        self._inboxTracker = StateObject(wrappedValue: newInboxTracker)
        self._replyTracker = StateObject(wrappedValue: newReplyTracker)
        self._mentionTracker = StateObject(wrappedValue: newMentionTracker)
        self._messageTracker = StateObject(wrappedValue: newMessageTracker)
    }
    
    @State var curTab: InboxTab = .all
    
    var body: some View {
        content
            .navigationTitle("Inbox")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarColor()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    navBarTitle
                        .opacity(scrollToTopAppeared ? 0 : 1)
                        .animation(.easeOut(duration: 0.2), value: scrollToTopAppeared)
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) { ellipsisMenu }
            }
            .hoistNavigation {
                withAnimation {
                    scrollProxy?.scrollTo(scrollToTop)
                }
                return true
            }
            .handleLemmyViews()
            .environmentObject(inboxTracker)
            .task {
                // wrapping in task so view redraws don't cancel
                Task(priority: .userInitiated) {
                    await refresh()
                }
            }
            .onChange(of: shouldFilterRead) { newValue in
                Task(priority: .userInitiated) {
                    await handleShouldFilterReadChange(newShouldFilterRead: newValue)
                }
            }
    }
    
    @ViewBuilder
    private var content: some View {
        ScrollView {
            feed
        }
        .onChange(of: curTab) { _ in
            scrollProxy?.scrollTo(scrollToTop)
        }
        .fancyTabScrollCompatible()
        .refreshable {
            // wrapping in task so view redraws don't cancel
            Task {
                do {
                    let unreadCounts = try await personRepository.getUnreadCounts()
                    unreadTracker.update(with: unreadCounts)
                } catch {
                    errorHandler.handle(error)
                }
            }
            // awaiting the value makes the refreshable indicator properly wait for the call to finish
            await Task {
                await refresh()
            }.value
        }
    }
    
    @ViewBuilder
    var feed: some View {
        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
            ScrollToView(appeared: $scrollToTopAppeared)
                .id(scrollToTop)
            
            FeedHeaderView(feedType: InboxFeed.inbox, showDropdownIndicator: false)
            
            Section {
                if errorOccurred {
                    errorView()
                } else {
                    switch curTab {
                    case .all:
                        AllItemsFeedView(inboxTracker: inboxTracker)
                    case .replies:
                        RepliesFeedView(replyTracker: replyTracker)
                    case .mentions:
                        MentionsFeedView(mentionTracker: mentionTracker)
                    case .messages:
                        MessagesFeedView(messageTracker: messageTracker)
                    }
                }
            } header: {
                BubblePicker(InboxTab.allCases, selected: $curTab, withDividers: [.bottom]) { tab in
                    Text(tab.label)
                }
                .background(Color.systemBackground.opacity(scrollToTopAppeared ? 1 : 0))
                .background(.bar)
                .animation(.easeOut(duration: 0.2), value: scrollToTopAppeared)
            }
        }
    }
    
    @ViewBuilder
    func errorView() -> some View {
        VStack(spacing: 10) {
            Image(systemName: Icons.noPosts)
                .font(.title)
            
            Text("Inbox loading failed!")
            
            Text(errorMessage)
        }
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
    }
    
    @ViewBuilder
    private var ellipsisMenu: some View {
        Menu {
            ForEach(genMenuFunctions()) { item in
                MenuButton(menuFunction: item, menuFunctionPopup: .constant(nil)) // no destructive functions
            }
        } label: {
            Label("More", systemImage: Icons.menuCircle)
                .frame(height: AppConstants.barIconHitbox)
                .contentShape(Rectangle())
        }
    }
    
    @ViewBuilder
    var navBarTitle: some View {
        // this is a bit silly as its own view right now but it will be a menu once mod mail is implemented
        Text(InboxFeed.inbox.label)
            .font(.headline)
    }
}
