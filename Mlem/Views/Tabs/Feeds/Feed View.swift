//
//  Feed View (new).swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-21.
//

import Foundation
import SwiftUI

struct FeedView: View {
    
    // MARK: Environment and settings
    
    @AppStorage("shouldShowCommunityHeaders") var shouldShowCommunityHeaders: Bool = false
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
    @AppStorage("shouldShowPostCreator") var shouldShowPostCreator: Bool = true
    @AppStorage("postSize") var postSize: PostSize = .large
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var filtersTracker: FiltersTracker
    
    // MARK: Parameters and init
    
    let community: APICommunity?
    @State var feedType: FeedType
    let showLoading: Bool
    
    init(community: APICommunity?, feedType: FeedType, showLoading: Bool = false) {
        self.community = community
        self._feedType = State(initialValue: feedType)
        self.showLoading = showLoading
    }
    
    // MARK: State
    
    @StateObject var postTracker: PostTracker = .init(shouldPerformMergeSorting: false)
    
    @State var postSortType: PostSortType = .hot
    @State var isLoading: Bool = false
    
    // MARK: - Views
    
    var body: some View {
        contentView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .task(priority: .userInitiated) { await initFeed() }
            .refreshable { await refreshFeed() }
            .environmentObject(postTracker)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private var contentView: some View {
        if postTracker.items.isEmpty {
            noPostsView()
        } else {
            feed(for: postTracker.items)
        }
    }
    
    @ViewBuilder
    private func feed(for postViews: [APIPostView]) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(postViews) { postView in
                    VStack(spacing: 0) {
                        NavigationLink(value: PostLinkWithContext(post: postView, postTracker: postTracker)) {
                            FeedPost(
                                postView: postView,
                                showPostCreator: shouldShowPostCreator,
                                showCommunity: false,
                                responseItem: Binding.constant(nil)
                            )
                        }
                        Divider()
                    }
                    .buttonStyle(EmptyButtonStyle()) // Make it so that the link doesn't mess with the styling
                    .onAppear {
                        Task(priority: .medium) {
                            if postTracker.shouldLoadContent(after: postView) {
                                print("loading content after \(postView.post.name)")
                                await loadFeed()
                            }
                        }
                    }
                }
            }
        }
        .fancyTabScrollCompatible()
    }
    
    @ViewBuilder
    private func noPostsView() -> some View {
        if isLoading {
            LoadingView(whatIsLoading: .posts)
        } else {
            VStack(alignment: .center, spacing: 5) {
                Image(systemName: "text.bubble")

                Text("No posts to be found")
            }
            .padding()
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
        }
    }
}
