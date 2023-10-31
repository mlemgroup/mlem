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
    @StateObject var inboxTracker: InboxTracker
    @StateObject var replyTracker: ReplyTracker
    @StateObject var mentionTracker: MentionTracker
    @StateObject var messageTracker: MessageTracker
    @StateObject var dummyPostTracker: PostTracker // used for navigation
    
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
        
        newReplyTracker.setParentTracker(newInboxTracker)
        newMentionTracker.setParentTracker(newInboxTracker)
        newMessageTracker.setParentTracker(newInboxTracker)
        
        self._inboxTracker = StateObject(wrappedValue: newInboxTracker)
        self._replyTracker = StateObject(wrappedValue: newReplyTracker)
        self._mentionTracker = StateObject(wrappedValue: newMentionTracker)
        self._messageTracker = StateObject(wrappedValue: newMessageTracker)
        
        self._dummyPostTracker = StateObject(wrappedValue: .init(internetSpeed: internetSpeed, upvoteOnSave: upvoteOnSave))
    }
    
    // input state handling
    // - current view
    @State var curTab: InboxTab = .all
    
    // utility
    @StateObject private var inboxTabNavigation: AnyNavigationPath<AppRoute> = .init()
    
    var body: some View {
        // NOTE: there appears to be a SwiftUI issue with segmented pickers stacked on top of ScrollViews which causes the tab bar to appear fully transparent. The internet suggests that this may be a bug that only manifests in dev mode, so, unless this pops up in a build, don't worry about it. If it does manifest, we can either put the Picker *in* the ScrollView (bad because then you can't access it without scrolling to the top) or put a Divider() at the bottom of the VStack (bad because then the material tab bar doesn't show)
        NavigationStack(path: $inboxTabNavigation.path) {
            contentView
                .navigationTitle("Inbox")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarColor()
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) { ellipsisMenu }
                }
                .listStyle(PlainListStyle())
                .handleLemmyViews()
                .environmentObject(inboxTracker)
                .onChange(of: shouldFilterRead) { newValue in
                    Task(priority: .userInitiated) {
                        await handleShouldFilterReadChange(newShouldFilterRead: newValue)
                    }
                }
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
            .padding(.horizontal, AppConstants.postAndCommentSpacing)
            .padding(.top, AppConstants.postAndCommentSpacing)
            
            ScrollView(showsIndicators: true) {
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
            }
            .fancyTabScrollCompatible()
            .refreshable {
                // wrapping in task so view redraws don't cancel
                // awaiting the value makes the refreshable indicator properly wait for the call to finish
                await Task {
                    await refresh()
                }.value
            }
        }
        .task {
            // wrapping in task so view redraws don't cancel
            Task(priority: .userInitiated) {
                await refresh()
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
