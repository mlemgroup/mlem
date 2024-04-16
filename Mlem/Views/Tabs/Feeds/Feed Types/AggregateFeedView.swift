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
    @Dependency(\.siteInformation) var siteInformation
    @Dependency(\.markReadBatcher) var markReadBatcher
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.scrollViewProxy) var scrollProxy
    @Environment(\.navigationPathWithRoutes) private var navigationPath
    
    @EnvironmentObject var appState: AppState
    
    @StateObject var postTracker: StandardPostTracker
    @StateObject var savedContentTracker: UserContentTracker
    
    @State var postSortType: PostSortType
    
    @Binding var selectedFeed: PostFeedType?
    @State var selectedSavedTab: UserContentFeedType = .all
    
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    private var scrollToTopId: Int? {
        postTracker.items.first?.id
    }
    
    init(selectedFeed: Binding<PostFeedType?>) {
        var feedType: PostFeedType = .all
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
            feedType: feedType == .saved ? .all : feedType
        ))
        
        // StateObject can't be optional so we initialize with a dummy user
        self._savedContentTracker = .init(wrappedValue: .init(internetSpeed: internetSpeed, userId: nil, saved: true))
        
        self._selectedFeed = selectedFeed
    }
    
    var availableFeeds: [PostFeedType] {
        var availableFeeds: [PostFeedType] = [.all, .local, .subscribed]
        if siteInformation.moderatorFeedAvailable {
            availableFeeds.append(.moderated)
        }
        if appState.currentActiveAccount != nil, !availableFeeds.contains(.saved) {
            availableFeeds.append(.saved)
        }
        return availableFeeds
    }
    
    var body: some View {
        content
            .environment(\.feedType, selectedFeed)
            .task(id: appState.currentActiveAccount) {
                if let userId = appState.currentActiveAccount?.id {
                    do {
                        try await savedContentTracker.updateUserId(to: userId)
                    } catch {
                        errorHandler.handle(error)
                    }
                }
            }
            .task(id: selectedFeed) {
                if let selectedFeed {
                    switch selectedFeed {
                    case .all, .local, .moderated, .subscribed:
                        await markReadBatcher.flush(includeStaged: true)
                        await postTracker.changeFeedType(to: selectedFeed)
                        postTracker.isStale = false
                    default:
                        return
                    }
                }
            }
            .refreshable {
                await Task {
                    do {
                        switch selectedFeed {
                        case .all, .local, .moderated, .subscribed:
                            await markReadBatcher.flush(includeStaged: true)
                            _ = try await postTracker.refresh(clearBeforeRefresh: false)
                        case .saved:
                            _ = try await savedContentTracker.refresh(clearBeforeRefresh: false)
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
                ToolbarItem(placement: .primaryAction) {
                    ToolbarEllipsisMenu {
                        FeedToolbarContent()
                    }
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
                    if selectedFeed == .saved {
                        BubblePicker(
                            UserContentFeedType.allCases,
                            selected: $selectedSavedTab,
                            withDividers: [.top, .bottom],
                            label: \.rawValue.capitalized
                        )
                    }
                }
                
                switch selectedFeed {
                case .all, .local, .moderated, .subscribed:
                    PostFeedView(postSortType: $postSortType, showCommunity: true)
                        .environmentObject(postTracker)
                case .saved:
                    UserContentFeedView(contentType: selectedSavedTab)
                        .environmentObject(savedContentTracker)
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
                MenuButton(menuFunction: menuFunction, menuFunctionPopup: .constant(nil))
            }
        } label: {
            if let selectedFeed, PostFeedType.allAggregateFeedCases.contains(selectedFeed) {
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
                MenuButton(menuFunction: menuFunction, menuFunctionPopup: .constant(nil))
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
