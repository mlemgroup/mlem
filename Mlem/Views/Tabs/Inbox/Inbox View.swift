//
//  Inbox.swift
//  Mlem
//
//  Created by Jake Shirley on 6/25/23.
//

import Foundation
import SwiftUI
import CachedAsyncImage

// NOTE:
// all of the subordinate views are defined as functions in extensions because otherwise the tracker logic gets *ugly*
struct InboxView: View {
    let spacing: CGFloat = 10
    
    let account: SavedAccount
    @State var lastKnownAccountId: Int = 0 // id of the last account loaded with
    
    @State var errorOccurred: Bool = false
    @State var errorMessage: String = ""
    
    @State var isLoading: Bool = true
    @State var allItems: [InboxItem] = .init()
    
    @StateObject var mentionsTracker: MentionsTracker = .init()
    @StateObject var messagesTracker: MessagesTracker = .init()
    @StateObject var repliesTracker: RepliesTracker = .init()
    
    // TODO: this jank needs to go, but that's a heavy lift. Currently using the trackers directly in the sub-views breaks scrolling in those views because parent state updates rerender them while loadNextPage calls are in-flight. 
    @State var allMentions: [APIPersonMentionView] = .init()
    @State var allMessages: [APIPrivateMessageView] = .init()
    @State var allReplies: [APICommentReplyView] = .init()
    
    // TODO: make private again
    @State var selectionSection = 0
    
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            
            VStack(spacing: 10) {
                Picker(selection: $selectionSection, label: Text("Profile Section")) {
                    Text("All").tag(0)
                    Text("Replies").tag(1)
                    Text("Mentions").tag(2)
                    Text("Messages").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                ScrollView(showsIndicators: false) {
                    if errorOccurred {
                        errorView()
                    } else {
                        inboxFeedView()
                        // TODO: re-enable this
//                        Group {
//                            switch selectionSection {
//                            case 0:
//                                inboxFeedView()
//                            case 1:
//                                repliesFeedView()
//                            case 2:
//                                mentionsFeedView()
//                            case 3:
//                                messagesFeedView()
//                            default:
//                                Text("how did we get here?")
//                            }
//                        }
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
