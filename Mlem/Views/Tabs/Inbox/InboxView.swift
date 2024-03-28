//
//  InboxView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-24.
//

import Dependencies
import Foundation
import SwiftUI

enum InboxSelection: FeedType {
    case personal, mod
    
    var label: String {
        switch self {
        case .personal: "Inbox"
        case .mod: "Mod Mail"
        }
    }
        
    var subtitle: String {
        switch self {
        case .personal: "Replies, mentions, and messages"
        case .mod: "Moderation and administration notifications"
        }
    }
    
    var color: Color? {
        switch self {
        case .personal: .purple
        case .mod: .green
        }
    }
    
    var iconName: String {
        switch self {
        case .personal: Icons.inbox
        case .mod: Icons.moderation
        }
    }
    
    var iconNameFill: String {
        switch self {
        case .personal: Icons.inboxFill
        case .mod: Icons.moderationFill
        }
    }
    
    var iconScaleFactor: CGFloat {
        switch self {
        case .personal: 0.55
        case .mod: 0.5
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

enum ModMailTab: String, CaseIterable, Identifiable {
    case all
    
    var id: Self { self }
    
    var label: String {
        rawValue.capitalized
    }
}

struct InboxView: View {
    @AppStorage("shouldFilterRead") var shouldFilterRead: Bool = false
    
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.siteInformation) var siteInformation
    @Dependency(\.personRepository) var personRepository
    
    @EnvironmentObject var unreadTracker: UnreadTracker
    
    @StateObject var inboxTracker: InboxTracker
    @StateObject var replyTracker: ReplyTracker
    @StateObject var mentionTracker: MentionTracker
    @StateObject var messageTracker: MessageTracker
    @StateObject var commentReportTracker: CommentReportTracker
    
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    
    @State var selectedInbox: InboxSelection = .personal
    @State var selectedInboxTab: InboxTab = .all
    @State var selectedModMailTab: ModMailTab = .all
    
    @State var errorOccurred: Bool = false
    @State var errorMessage: String = ""
    
    init() {
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("shouldFilterRead") var unreadOnly = false
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        
        let newReplyTracker = ReplyTracker(internetSpeed: internetSpeed, sortType: .published, unreadOnly: unreadOnly)
        let newMentionTracker = MentionTracker(internetSpeed: internetSpeed, sortType: .published, unreadOnly: unreadOnly)
        let newMessageTracker = MessageTracker(internetSpeed: internetSpeed, sortType: .published, unreadOnly: unreadOnly)
        let newCommentReportTracker = CommentReportTracker(internetSpeed: internetSpeed, sortType: .published, unreadOnly: unreadOnly)
        
        let newInboxTracker = InboxTracker(
            internetSpeed: internetSpeed,
            sortType: .published,
            childTrackers: [
                newReplyTracker,
                newMentionTracker,
                newMessageTracker,
                newCommentReportTracker
            ]
        )
        
        self._inboxTracker = StateObject(wrappedValue: newInboxTracker)
        self._replyTracker = StateObject(wrappedValue: newReplyTracker)
        self._mentionTracker = StateObject(wrappedValue: newMentionTracker)
        self._messageTracker = StateObject(wrappedValue: newMessageTracker)
        self._commentReportTracker = StateObject(wrappedValue: newCommentReportTracker)
    }
    
    var availableFeeds: [InboxSelection] {
        var availableFeeds: [InboxSelection] = [.personal]
        if siteInformation.isAdmin || !siteInformation.moderatedCommunities.isEmpty {
            availableFeeds.append(.mod)
        }
        return availableFeeds
    }
    
    var body: some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    navBarTitle
                        .opacity(scrollToTopAppeared ? 0 : 1)
                        .animation(.easeOut(duration: 0.2), value: scrollToTopAppeared)
                }
                ToolbarItem(placement: .primaryAction) {
                    ToolbarEllipsisMenu {
                        FeedToolbarContent()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarColor(visibility: .automatic)
            .onChange(of: shouldFilterRead) { newValue in
                Task(priority: .userInitiated) {
                    await handleShouldFilterReadChange(newShouldFilterRead: newValue)
                }
            }
            .refreshable {
                // wrapping in task so view redraws don't cancel
                // awaiting the value makes the refreshable indicator properly wait for the call to finish
                await Task {
                    await refresh()
                }.value
            }
            .task {
                // wrapping in task so view redraws don't cancel
                Task(priority: .userInitiated) {
                    await refresh()
                }
            }
    }
    
    var content: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                ScrollToView(appeared: $scrollToTopAppeared)
                    .id(scrollToTop)
                
                headerView
  
                switch selectedInbox {
                case .personal:
                    personalInboxView
                case .mod:
                    modMailView
                }
            }
        }
        .fancyTabScrollCompatible()
    }
    
    @ViewBuilder
    var headerView: some View {
        Menu {
            ForEach(genFeedSwitchingFunctions()) { menuFunction in
                MenuButton(menuFunction: menuFunction, menuFunctionPopup: .constant(nil))
            }
        } label: {
            FeedHeaderView(feedType: selectedInbox)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    var navBarTitle: some View {
        Menu {
            ForEach(genFeedSwitchingFunctions()) { menuFunction in
                MenuButton(menuFunction: menuFunction, menuFunctionPopup: .constant(nil))
            }
        } label: {
            HStack(alignment: .center, spacing: 0) {
                Text(selectedInbox.label)
                    .font(.headline)
                Image(systemName: Icons.dropdown)
                    .scaleEffect(0.7)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.primary)
            .accessibilityElement(children: .combine)
            .accessibilityHint("Activate to change feeds.")
            // this disables the implicit animation on the header view...
            .transaction { $0.animation = nil }
        }
    }
    
    @ViewBuilder
    var ellipsisMenu: some View {
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
    var personalInboxView: some View {
        Section {
            switch selectedInboxTab {
            case .all:
                AllItemsFeedView(inboxTracker: inboxTracker)
            case .replies:
                RepliesFeedView(replyTracker: replyTracker)
            case .mentions:
                MentionsFeedView(mentionTracker: mentionTracker)
            case .messages:
                MessagesFeedView(messageTracker: messageTracker)
            }
        } header: {
            BubblePicker(InboxTab.allCases, selected: $selectedInboxTab, withDividers: [.bottom]) { tab in
                Text(tab.label)
            }
            .background(Color.systemBackground.opacity(scrollToTopAppeared ? 1 : 0))
            .background(.bar)
            .animation(.easeOut(duration: 0.2), value: scrollToTopAppeared)
        }
    }
    
    @ViewBuilder
    var modMailView: some View {
        Section {
            LazyVStack(spacing: 0) {
                ForEach(commentReportTracker.items, id: \.uid) { item in
                    InboxCommentReportView(commentReport: item)
                }
            }
        } header: {
            BubblePicker(ModMailTab.allCases, selected: $selectedModMailTab, withDividers: [.bottom]) { tab in
                Text(tab.label)
            }
            .background(Color.systemBackground.opacity(scrollToTopAppeared ? 1 : 0))
            .background(.bar)
            .animation(.easeOut(duration: 0.2), value: scrollToTopAppeared)
        }
    }
}
