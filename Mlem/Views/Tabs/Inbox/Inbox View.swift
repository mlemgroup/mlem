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

// NOTE:
// all of the subordinate views are defined as functions in extensions because otherwise the tracker logic gets *ugly*
struct InboxView: View {
    // MARK: Global
    @EnvironmentObject var appState: AppState
    
    // MARK: Parameters
    let account: SavedAccount
    
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
    
    // input state handling
    // - current view
    @State var curTab: InboxTab = .all
    
    // - replies and messages
    @State var isComposingMessage: Bool = false
    @State var messageRecipient: APIPerson?
    
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            
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
                
                Spacer()
            }
            // load view if empty or account has changed
            .task(priority: .userInitiated) {
                // if a tracker is empty or the account has changed, refresh
                if mentionsTracker.items.isEmpty ||
                    messagesTracker.items.isEmpty ||
                    repliesTracker.items.isEmpty  ||
                    lastKnownAccountId != account.id {
                    print("Inbox tracker is empty")
                    await refreshFeed()
                } else {
                    print("Inbox tracker is not empty")
                }
                lastKnownAccountId = account.id
            }
            .sheet(isPresented: $isComposingMessage) {
                if let recipient = messageRecipient {
                    MessageComposerView(recipient: recipient)
                }
            }
            .navigationTitle("Inbox")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(PlainListStyle())
            .handleLemmyViews(navigationPath: $navigationPath)
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
