//
//  Inbox View.swift
//  Mlem
//
//  Created by Jake Shirley on 6/25/23.
//

import Dependencies
import Foundation
import SwiftUI

enum InboxTab: String, CaseIterable, Identifiable {
    case all, replies, mentions, messages
    
    var id: Self { self }
    
    var label: String {
        rawValue.capitalized
    }
}

enum ComposingTypes {
    case commentReply(APICommentReplyView?)
    case mention(APIPersonMentionView?)
    case message(APIPerson?)
}

// NOTE:
// all of the subordinate views are defined as functions in extensions because otherwise the tracker logic gets *ugly*
struct InboxView: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.commentRepository) var commentRepository
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.notifier) var notifier
    @Dependency(\.personRepository) var personRepository
    
    // MARK: Global

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var unreadTracker: UnreadTracker
    
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    @Environment(\.tabNavigationSelectionHashValue) private var selectedNavigationTabHashValue

    @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
    
    // MARK: Internal
    
    // destructive confirmation
    @State var isPresentingConfirmDestructive: Bool = false
    @State var confirmationMenuFunction: StandardMenuFunction?
    
    func confirmDestructive(destructiveFunction: StandardMenuFunction) {
        confirmationMenuFunction = destructiveFunction
        isPresentingConfirmDestructive = true
    }
    
    // error  handling
    @State var errorOccurred: Bool = false
    @State var errorMessage: String = ""
    
    // loading handling
    @State var isLoading: Bool = true
    @AppStorage("shouldFilterRead") var shouldFilterRead: Bool = false
    
    // item feeds
    @State var allItems: [InboxItem] = .init()
    @StateObject var mentionsTracker: MentionsTracker = .init()
    @StateObject var messagesTracker: MessagesTracker = .init()
    @StateObject var repliesTracker: RepliesTracker = .init()
    @StateObject var dummyPostTracker: PostTracker // used for navigation
    
    init() {
        // TODO: once the post tracker is changed we won't need this here...
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        self._dummyPostTracker = StateObject(wrappedValue: .init(internetSpeed: internetSpeed, upvoteOnSave: upvoteOnSave))
    }
    
    // input state handling
    // - current view
    @State var curTab: InboxTab = .all
    
    // utility
    @StateObject private var inboxRouter: NavigationRouter<NavigationRoute> = .init()
    
    var body: some View {
        // NOTE: there appears to be a SwiftUI issue with segmented pickers stacked on top of ScrollViews which causes the tab bar to appear fully transparent. The internet suggests that this may be a bug that only manifests in dev mode, so, unless this pops up in a build, don't worry about it. If it does manifest, we can either put the Picker *in* the ScrollView (bad because then you can't access it without scrolling to the top) or put a Divider() at the bottom of the VStack (bad because then the material tab bar doesn't show)
        NavigationStack(path: $inboxRouter.path) {
            contentView
                .navigationTitle("Inbox")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarColor()
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) { ellipsisMenu }
                }
                .listStyle(PlainListStyle())
                .handleLemmyViews()
                .onChange(of: selectedTagHashValue) { newValue in
                    if newValue == TabSelection.inbox.hashValue {
                        print("switched to inbox tab")
                    }
                }
                .onChange(of: selectedNavigationTabHashValue) { newValue in
                    if newValue == TabSelection.inbox.hashValue {
                        print("re-selected \(TabSelection.inbox) tab")
                    }
                }
        }
    }
    
    @ViewBuilder var contentView: some View {
        VStack(spacing: AppConstants.postAndCommentSpacing) {
            Picker(selection: $curTab, label: Text("Inbox tab")) {
                ForEach(InboxTab.allCases) { tab in
                    Text(tab.label).tag(tab.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            ScrollView(showsIndicators: false) {
                if errorOccurred {
                    errorView()
                } else {
                    switch curTab {
                    case .all:
                        inboxFeedView()
                    case .replies:
                        repliesFeedView()
                    case .mentions:
                        mentionsFeedView()
                    case .messages:
                        messagesFeedView()
                    }
                }
            }
            .fancyTabScrollCompatible()
            .refreshable {
                Task(priority: .userInitiated) {
                    await refreshFeed()
                }
            }
        }
        // load view if empty or account has changed
        .task(priority: .userInitiated) {
            // if a tracker is empty or the account has changed, refresh
            if mentionsTracker.items.isEmpty ||
                messagesTracker.items.isEmpty ||
                repliesTracker.items.isEmpty {
                print("Inbox tracker is empty")
                await refreshFeed()
            } else {
                print("Inbox tracker is not empty")
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
            ForEach(genMenuFunctions()) { menuFunction in
                MenuButton(menuFunction: menuFunction, confirmDestructive: nil) // no destructive functions
            }
        } label: {
            Label("More", systemImage: "ellipsis")
                .frame(height: AppConstants.barIconHitbox)
                .contentShape(Rectangle())
        }
    }
}
