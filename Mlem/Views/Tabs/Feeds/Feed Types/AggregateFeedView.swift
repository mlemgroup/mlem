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
    @Dependency(\.markReadBatcher) var markReadBatcher
    
    @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
    @AppStorage("showReadPosts") var showReadPosts = true
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.scrollViewProxy) var scrollProxy
    @Environment(\.navigationPathWithRoutes) private var navigationPath
    
    @Environment(AppState.self) var appState
    
    @State var postTracker: StandardPostTracker?
    // @State var savedContentTracker: UserContentTracker?
    
    @State var postSortType: PostSortType
    @State var availableFeeds: [FeedType] = [.all, .local, .subscribed]
    
    @Binding var selectedFeed: FeedType?
    
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    
    private var scrollToTopId: Int? { postTracker?.items.first?.id }
    
    init(appState: AppState, selectedFeed: Binding<FeedType?>) {
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
        
        self._selectedFeed = selectedFeed
        
        self._postSortType = .init(wrappedValue: defaultPostSorting)
        if let apiSource = appState.apiSource {
            self._postTracker = .init(wrappedValue: .init(
                internetSpeed: internetSpeed,
                sortType: defaultPostSorting,
                showReadPosts: showReadPosts,
                feedType: .aggregateFeed(apiSource, type: feedType.toApiListingType)
            )
            )
        } else {
            self._postTracker = .init(wrappedValue: nil)
        }
        
        // StateObject can't be optional so we initialize with a dummy user
        // self.savedContentTracker = .init(internetSpeed: internetSpeed, userId: nil, saved: true)
    }
    
    var body: some View {
        content
            .environment(\.feedType, selectedFeed)
            .task(id: selectedFeed) {
                if let selectedFeed, let apiSource = appState.apiSource {
                    switch selectedFeed {
                    case .all, .local, .subscribed:
                        await markReadBatcher.flush()
                        await postTracker?.changeFeedType(to: .aggregateFeed(apiSource, type: selectedFeed.toApiListingType))
                        postTracker?.isStale = false
                    default:
                        return
                    }
                }
            }
            .onChange(of: appState.apiSource?.actorId) { oldValue, _ in
                if oldValue == nil, let apiSource = appState.apiSource {
                    postTracker = .init(
                        internetSpeed: internetSpeed,
                        sortType: postSortType,
                        showReadPosts: showReadPosts,
                        feedType: postTracker?.feedType ?? .aggregateFeed(apiSource, type: selectedFeed?.toApiListingType ?? .all)
                    )
                }
            }
            .refreshable {
                await Task {
                    do {
                        switch selectedFeed {
                        case .all, .local, .subscribed:
                            await markReadBatcher.flush()
                            _ = try await postTracker?.refresh(clearBeforeRefresh: false)
                        case .saved:
                            break
                        // _ = try await savedContentTracker?.refresh(clearBeforeRefresh: false)
                        default:
                            assertionFailure("Tried to refresh with invalid feed type \(String(describing: selectedFeed))")
                        }
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
            .hoistNavigation {
                if let scrollProxy {
                    withAnimation {
                        scrollProxy.scrollTo(scrollToTop)
                    }
                }
                return !scrollToTopAppeared
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarColor(visibility: .automatic)
    }
    
    @ViewBuilder
    var content: some View {
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
                    if let postTracker {
                        PostFeedView(appState: appState, postSortType: $postSortType, showCommunity: true)
                            .environment(postTracker)
                    } else {
                        Text(appState.apiSource?.actorId.absoluteString ?? "No tracker")
                        LoadingView(whatIsLoading: .posts)
                    }
                case .saved:
//                    if let savedContentTracker {
//                        UserContentFeedView()
//                            .environment(savedContentTracker)
//                    } else {
                    LoadingView(whatIsLoading: .content)
                // }
                default:
                    EmptyView() // shouldn't be possible
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
            if let selectedFeed, FeedType.allAggregateFeedCases.contains(selectedFeed) {
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
