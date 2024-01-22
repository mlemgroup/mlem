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
    
    @State var postSortType: PostSortType
    
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    private var scrollToTopId: Int? {
        postTracker.items.first?.id
    }
    
    init(feedType: NewFeedType) {
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
    }
    
    var subtitle: String {
        switch postTracker.feedType {
        case .all:
            return "Posts from all federated instances"
        case .local:
            return "Posts from \(appState.currentActiveAccount?.instanceLink.host() ?? "your instance's") communities"
        case .subscribed:
            return "Posts from all subscribed communities"
        case .saved:
            return "Your saved posts"
        default:
            assertionFailure("We shouldn't be here...")
            return ""
        }
    }
    
    var body: some View {
        content
            .environmentObject(postTracker)
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
                    
                    PostFeedView(postSortType: $postSortType, showCommunity: true)
                        .environmentObject(postTracker)
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
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: AppConstants.postAndCommentSpacing) {
                    Image(systemName: postTracker.feedType.iconNameCircle)
                        .resizable()
                        .frame(width: 44, height: 44)
                        .foregroundStyle(postTracker.feedType.color ?? .primary)
                        .padding(.leading, AppConstants.postAndCommentSpacing)
                        
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 5) {
                            Text(postTracker.feedType.label)
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .fontWeight(.semibold)
                            Image(systemName: Icons.dropdown)
                                .foregroundStyle(.secondary)
                        }
                        .font(.title2)
                            
                        Text(subtitle)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .frame(height: 44)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 5)
                    
                Divider()
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
                Text(postTracker.feedType.label)
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
