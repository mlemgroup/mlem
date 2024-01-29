//
//  AggregateFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-11.
//

import Dependencies
import Foundation
import SwiftUI

/// View for post feeds aggregating multiple communities (all, local, subscribed, saved)
struct AggregateFeedView: View {
    @Dependency(\.errorHandler) var errorHandler
    
    @EnvironmentObject var appState: AppState
    
    @StateObject var postTracker: StandardPostTracker
    @StateObject var savedContentTracker: UserContentTracker
    
    @State var postSortType: PostSortType
    @State var availableFeeds: [FeedType] = [.all, .local, .subscribed]
    
    @Binding var selectedFeed: FeedType?
    
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    private var scrollToTopId: Int? {
        postTracker.items.first?.id
    }
    
    init(selectedFeed: Binding<FeedType?>) {
        var feedType: FeedType = .all
        if let selectedFeed = selectedFeed.wrappedValue {
            feedType = selectedFeed
        } else {
            assertionFailure("nil feedType passed in to AggregateFeedView!")
        }
        
        // need to grab some stuff from app storage to initialize with
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        @AppStorage("showReadPosts") var showReadPosts = true
        @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
        
        self._postSortType = .init(wrappedValue: defaultPostSorting)
        self._postTracker = .init(wrappedValue: .init(
            internetSpeed: internetSpeed,
            sortType: defaultPostSorting,
            showReadPosts: showReadPosts,
            feedType: feedType
        ))
        
        // StateObject can't be optional so we initialize with a dummy user
        self._savedContentTracker = .init(wrappedValue: .init(internetSpeed: internetSpeed, userId: nil, saved: true))
        
        self._selectedFeed = selectedFeed
    }
    
    var body: some View {
        content
            .environment(\.feedType, selectedFeed)
            .task(id: appState.currentActiveAccount) {
                // ensure that .saved isn't an available feed until user id resolved
                if let userId = appState.currentActiveAccount?.id {
                    do {
                        try await savedContentTracker.updateUserId(to: userId)
                        
                        if availableFeeds.count < 4 {
                            availableFeeds.append(.saved)
                        }
                    } catch {
                        errorHandler.handle(error)
                    }
                }
            }
            .task(id: selectedFeed) {
                if let selectedFeed, selectedFeed != .saved {
                    await postTracker.changeFeedType(to: selectedFeed)
                    postTracker.isStale = false
                }
            }
            .refreshable {
                await Task {
                    do {
                        _ = try await postTracker.refresh(clearBeforeRefresh: false)
                    } catch {
                        errorHandler.handle(error)
                    }
                }.value
            }
            .background {
                Color.systemBackground
            }
            .fancyTabScrollCompatible()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    navBarTitle
                        .opacity(scrollToTopAppeared ? 0 : 1)
                        .animation(.easeOut(duration: 0.2), value: scrollToTopAppeared)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarColor(visibility: .automatic)
    }
    
    @ViewBuilder
    var content: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        ScrollToView(appeared: $scrollToTopAppeared)
                            .id(scrollToTop)
                        headerView
                            .padding(.top, -1)
                    }
                    
                    switch selectedFeed {
                    case .all, .local, .subscribed:
                        PostFeedView(postSortType: $postSortType, showCommunity: true)
                            .environmentObject(postTracker)
                    case .saved:
                        UserContentFeedView()
                            .environmentObject(savedContentTracker)
                    default:
                        EmptyView() // shouldn't be possible
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var headerView: some View {
        Menu {
            ForEach(genFeedSwitchingFunctions()) { menuFunction in
                MenuButton(menuFunction: menuFunction, confirmDestructive: nil)
            }
        } label: {
            if let selectedFeed {
                FeedHeaderView(feedType: selectedFeed)
            } else {
                EmptyView() // shouldn't be possible
            }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    var navBarTitle: some View {
        Menu {
            ForEach(genFeedSwitchingFunctions()) { menuFunction in
                MenuButton(menuFunction: menuFunction, confirmDestructive: nil)
            }
        } label: {
            HStack(alignment: .center, spacing: 0) {
                Text(selectedFeed?.label ?? "")
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
}
