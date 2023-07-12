//
//  Inbox.swift
//  Mlem
//
//  Created by Jake Shirley on 6/25/23.
//

import Foundation
import SwiftUI
import CachedAsyncImage

enum InboxTab: String, CaseIterable, Identifiable {
    case all, replies, mentions, messages
    
    var id: Self { self }
    
    var label: String {
        return self.rawValue.capitalized
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
    // MARK: Global
    @EnvironmentObject var appState: AppState
    
    // MARK: Internal
    // id of the last account loaded with
    @State var lastKnownAccountId: Int = 0
    
    // error  handling
    @State var errorOccurred: Bool = false
    @State var errorMessage: String = ""
    
    // loading handling
    @State var isLoading: Bool = true
    
    // item feeds
    @State var allItems: [InboxItem] = .init()
    @StateObject var mentionsTracker: MentionsTracker = .init()
    @StateObject var messagesTracker: MessagesTracker = .init()
    @StateObject var repliesTracker: RepliesTracker = .init()
    @StateObject var dummyPostTracker: PostTracker = .init() // used for nav
    
    // input state handling
    // - current view
    @State var curTab: InboxTab = .all
    
    // - replies and messages
    @State var isComposing: Bool = false
    @State var composingTo: ComposingTypes = .commentReply(nil)
    
    // utility
    @State var isDragging: Bool = false
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        // NOTE: there appears to be a SwiftUI issue with segmented pickers stacked on top of Views which causes the tab bar to appear fully transparent. The internet suggests that this may be a bug that only manifests in dev mode, so, unless this pops up in a build, don't worry about it. If it does manifest, we can either put the Picker *in* the ScrollView (bad because then you can't access it without scrolling to the top) or put a Divider() at the bottom of the VStack (bad because then the material tab bar doesn't show)
        NavigationStack(path: $navigationPath) {
            contentView
                .navigationTitle("Inbox")
                .navigationBarTitleDisplayMode(.inline)
                .listStyle(PlainListStyle())
                .handleLemmyViews()
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
            .refreshable {
                Task(priority: .userInitiated) {
                    await refreshFeed()
                }
            }
        }
        .sheet(isPresented: $isComposing) { [isComposing] in // capture here to force state re-eval
            switch composingTo {
            case .commentReply(let commentReplyingTo):
                if let commentReply = commentReplyingTo {
                    let replyTo = ReplyToCommentReply(commentReply: commentReply,
                                                      appState: appState)
                    GeneralCommentComposerView(replyTo: replyTo)
                }
            case .mention(let mentionReplyingTo):
                if let mentionReply = mentionReplyingTo {
                    let replyTo = ReplyToMention(mention: mentionReply, appState: appState)
                    GeneralCommentComposerView(replyTo: replyTo)
                }
            case .message(let personReplyingTo):
                if let recipient = personReplyingTo {
                    MessageComposerView(recipient: recipient)
                        .presentationDetents([.medium, .large])
                }
            }
        }
        // load view if empty or account has changed
        .task(priority: .userInitiated) {
            // if a tracker is empty or the account has changed, refresh
            if mentionsTracker.items.isEmpty ||
                messagesTracker.items.isEmpty ||
                repliesTracker.items.isEmpty  ||
                lastKnownAccountId != appState.currentActiveAccount.id {
                print("Inbox tracker is empty")
                await refreshFeed()
            } else {
                print("Inbox tracker is not empty")
            }
            lastKnownAccountId = appState.currentActiveAccount.id
        }
    }
    
    @ViewBuilder
    func errorView() -> some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.bubble")
                .font(.title)
            
            Text("Inbox loading failed!")
            
            Text(errorMessage)
        }
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
    }
}
