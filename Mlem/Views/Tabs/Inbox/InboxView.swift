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
    
    func enrichedLabel(unread: Int) -> String {
        if unread > 0 {
            return "\(label) (\(unread))"
        }
        return label
    }
        
    var subtitle: String {
        switch self {
        case .personal: "Replies, mentions, and messages"
        case .mod: "Reports from communities you moderate"
        }
    }
    
    var color: Color? {
        switch self {
        case .personal: .purple
        case .mod: .moderation
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
    case all, replies, mentions, messages, commentReports, postReports, messageReports, registrationApplications
    
    static var personalCases: [InboxTab] { [.all, .replies, .mentions, .messages] }
    static var modCases: [InboxTab] { [.all, .commentReports, .postReports] }
    static var adminCases: [InboxTab] { [.all, .registrationApplications, .messageReports, .commentReports, .postReports] }
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .commentReports: "Comments"
        case .postReports: "Posts"
        case .messageReports: "Messages"
        case .registrationApplications: "Applications"
        default:
            rawValue.capitalized
        }
    }
}

struct InboxView: View {
    @AppStorage("shouldFilterRead") var shouldFilterRead: Bool = false
    
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.siteInformation) var siteInformation
    @Dependency(\.personRepository) var personRepository
    @Dependency(\.notifier) var notifier
    
    @Environment(\.scrollViewProxy) var scrollViewProxy
    
    @EnvironmentObject var unreadTracker: UnreadTracker
    
    // personal tracker + children
    @StateObject var personalInboxTracker: InboxTracker
    @StateObject var replyTracker: ReplyTracker
    @StateObject var mentionTracker: MentionTracker
    @StateObject var messageTracker: MessageTracker
    // mod/admin trackers + children
    @StateObject var modInboxTracker: InboxTracker
    @StateObject var adminInboxTracker: InboxTracker
    @StateObject var commentReportTracker: CommentReportTracker
    @StateObject var postReportTracker: PostReportTracker
    @StateObject var messageReportTracker: MessageReportTracker
    @StateObject var registrationApplicationTracker: RegistrationApplicationTracker
    
    @Namespace var scrollToTop
    @State var scrollToTopAppeared = false
    
    @State var selectedInbox: InboxSelection = .personal
    @State var selectedPersonalTab: InboxTab = .all
    @State var selectedModTab: InboxTab = .all
    
    @State var errorOccurred: Bool = false
    @State var errorMessage: String = ""
    
    // swiftlint:disable:next function_body_length
    init() {
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("shouldFilterRead") var unreadOnly = false
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        
        let modSortType: TrackerSort.Case = unreadOnly ? .old : .new
        
        let newReplyTracker = ReplyTracker(internetSpeed: internetSpeed, sortType: .new, unreadOnly: unreadOnly)
        let newMentionTracker = MentionTracker(internetSpeed: internetSpeed, sortType: .new, unreadOnly: unreadOnly)
        let newMessageTracker = MessageTracker(internetSpeed: internetSpeed, sortType: .new, unreadOnly: unreadOnly)
        let newCommentReportTracker = CommentReportTracker(internetSpeed: internetSpeed, sortType: modSortType, unreadOnly: unreadOnly)
        let newPostReportTracker = PostReportTracker(internetSpeed: internetSpeed, sortType: modSortType, unreadOnly: unreadOnly)
        let newMessageReportTracker = MessageReportTracker(internetSpeed: internetSpeed, sortType: modSortType, unreadOnly: unreadOnly)
        let newRegistrationApplicationTracker = RegistrationApplicationTracker(
            internetSpeed: internetSpeed,
            sortType: modSortType,
            unreadOnly: unreadOnly
        )
        
        let newPersonalInboxTracker = InboxTracker(
            internetSpeed: internetSpeed,
            sortType: .new,
            childTrackers: [
                newReplyTracker,
                newMentionTracker,
                newMessageTracker
            ]
        )
        
        let newModInboxTracker = InboxTracker(
            internetSpeed: internetSpeed,
            sortType: modSortType,
            childTrackers: [
                newCommentReportTracker,
                newPostReportTracker
            ]
        )
        
        let newAdminInboxTracker = InboxTracker(
            internetSpeed: internetSpeed,
            sortType: modSortType,
            childTrackers: [
                newCommentReportTracker,
                newPostReportTracker,
                newMessageReportTracker,
                newRegistrationApplicationTracker
            ]
        )
        
        self._personalInboxTracker = StateObject(wrappedValue: newPersonalInboxTracker)
        self._modInboxTracker = StateObject(wrappedValue: newModInboxTracker)
        self._adminInboxTracker = StateObject(wrappedValue: newAdminInboxTracker)
        self._replyTracker = StateObject(wrappedValue: newReplyTracker)
        self._mentionTracker = StateObject(wrappedValue: newMentionTracker)
        self._messageTracker = StateObject(wrappedValue: newMessageTracker)
        self._commentReportTracker = StateObject(wrappedValue: newCommentReportTracker)
        self._postReportTracker = StateObject(wrappedValue: newPostReportTracker)
        self._messageReportTracker = StateObject(wrappedValue: newMessageReportTracker)
        self._registrationApplicationTracker = StateObject(wrappedValue: newRegistrationApplicationTracker)
    }
    
    var showModFeed: Bool { siteInformation.isAdmin || !siteInformation.moderatedCommunities.isEmpty }
    
    var modOrAdminInboxTracker: InboxTracker { siteInformation.isAdmin ? adminInboxTracker : modInboxTracker }
    
    var customSubtitle: String? { selectedInbox == .mod && siteInformation.isAdmin ? "Registration applications and reports" : nil }
    
    var showDropdownBadge: Bool {
        switch selectedInbox {
        case .personal: unreadTracker.modAndAdmin > 0
        case .mod: unreadTracker.personal > 0
        }
    }
    
    var availableFeeds: [InboxSelection] {
        var availableFeeds: [InboxSelection] = [.personal]
        if showModFeed {
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
                    toolbarMenu
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarColor(visibility: .automatic)
            .onChange(of: shouldFilterRead) { newValue in
                Task(priority: .userInitiated) {
                    await handleShouldFilterReadChange(newShouldFilterRead: newValue)
                }
            }
            .environmentObject(modOrAdminInboxTracker)
            .environmentObject(personalInboxTracker)
            .refreshable {
                // wrapping in task so view redraws don't cancel
                // awaiting the value makes the refreshable indicator properly wait for the call to finish
                await Task {
                    switch selectedInbox {
                    case .personal:
                        await refresh(tracker: personalInboxTracker)
                    case .mod:
                        await refresh(tracker: modOrAdminInboxTracker)
                    }
                }.value
            }
            .hoistNavigation {
                if scrollToTopAppeared, availableFeeds.count > 1 {
                    guard showModFeed else {
                        assertionFailure("Multiple inbox feeds available for non-mod/admin!")
                        return true
                    }
                    switch selectedInbox {
                    case .personal:
                        selectedInbox = .mod
                    case .mod:
                        selectedInbox = .personal
                    }
                } else {
                    withAnimation {
                        scrollViewProxy?.scrollTo(scrollToTop)
                    }
                }
                return true
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
                    personalFeedView
                case .mod:
                    moderatorFeedView
                }
            }
        }
        .fancyTabScrollCompatible()
    }
    
    @ViewBuilder
    var headerView: some View {
        if showModFeed {
            Menu {
                ForEach(genFeedSwitchingFunctions()) { menuFunction in
                    MenuButton(menuFunction: menuFunction, menuFunctionPopup: .constant(nil))
                }
            } label: {
                FeedHeaderView(feedType: selectedInbox, customSubtitle: customSubtitle, showDropdownBadge: showDropdownBadge)
            }
            .buttonStyle(.plain)
        } else {
            FeedHeaderView(feedType: InboxSelection.personal, showDropdownIndicator: false)
        }
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
        ForEach(genMenuFunctions()) { item in
            MenuButton(menuFunction: item, menuFunctionPopup: .constant(nil)) // no destructive functions
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
    var toolbarMenu: some View {
        if selectedInbox == .personal {
            ToolbarEllipsisMenu {
                ellipsisMenu
            }
        } else {
            Button {
                let status = shouldFilterRead ? "All" : "Only Unresolved"
                toggleFilterRead()
                Task {
                    await notifier.add(.success("Showing \(status)"))
                }
            } label: {
                Label("Toggle Unread Only", systemImage: shouldFilterRead ? Icons.filterFill : Icons.filter)
            }
        }
    }
    
    @ViewBuilder
    func picker(tabs: [InboxTab], selected: Binding<InboxTab>) -> some View {
        BubblePicker(
            tabs,
            selected: selected,
            withDividers: [.bottom],
            label: \.label,
            value: { tabValue(for: $0) }
        )
        .background(Color.systemBackground.opacity(scrollToTopAppeared ? 1 : 0))
        .background(.bar)
        .animation(.easeOut(duration: 0.2), value: scrollToTopAppeared)
    }
}
