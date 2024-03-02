//
//  StandardPostFeedLoader.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-04.
//

import Dependencies
import Foundation
import Nuke
import SwiftUI

/// Enumeration of criteria on which to filter a post
enum PostFilter: Hashable {
    /// Post is filtered because it was read
    case read
    
    /// Post is filtered because it contains a blocked keyword
    case keyword
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .read:
            hasher.combine("read")
        case .keyword:
            hasher.combine("keyword")
        }
    }
}

enum TrackerFeedType: Equatable {
    case aggregateFeed(any PostFeedProvider, type: ApiListingType)
    case community(any Community)
    
    static func == (lhs: TrackerFeedType, rhs: TrackerFeedType) -> Bool {
        switch (lhs, rhs) {
        case let (.aggregateFeed(source1, type: type1), .aggregateFeed(source2, type: type2)):
            return source1.actorId == source2.actorId && type1 == type2
        case let (.community(comm1), .community(comm2)):
            return comm1.actorId == comm2.actorId
        default:
            return false
        }
    }
    
    func getPosts(
        sort: ApiSortType,
        page: Int = 1,
        cursor: String? = nil,
        limit: Int,
        savedOnly: Bool = false
    ) async throws -> (posts: [Post2], cursor: String?) {
        switch self {
        case let .aggregateFeed(api, type):
            return try await api.getPosts(feed: type, sort: sort, page: page, cursor: cursor, limit: limit, savedOnly: savedOnly)
        case let .community(community):
            return try await community.getPosts(sort: sort, page: page, cursor: cursor, limit: limit, savedOnly: savedOnly)
        }
    }
}

/// Post tracker for use with single feeds. Supports all post sorting types, but is not suitable for multi-feed use.
@Observable
class StandardPostTracker: StandardFeedLoader<Post2> {
    @ObservationIgnored @Dependency(\.persistenceRepository) var persistenceRepository
    
    // TODO: ERIC keyword filters could be more elegant
    var filteredKeywords: [String]
    
    var feedType: TrackerFeedType
    private(set) var postSortType: ApiSortType
    private var filters: [PostFilter: Int]
    
    // true when the items in the tracker are stale and should not be displayed
    var isStale: Bool = false
    
    // prefetching
    private let prefetcher = ImagePrefetcher(
        pipeline: ImagePipeline.shared,
        destination: .memoryCache,
        maxConcurrentRequestCount: 40
    )
    
    init(
        internetSpeed: InternetSpeed,
        sortType: ApiSortType,
        showReadPosts: Bool,
        feedType: TrackerFeedType
    ) {
        @Dependency(\.persistenceRepository) var persistenceRepository
                
        self.feedType = feedType
        self.postSortType = sortType
        
        self.filteredKeywords = persistenceRepository.loadFilteredKeywords()
        self.filters = [.keyword: 0]
        
        super.init(internetSpeed: internetSpeed)
        
        if !showReadPosts {
            filters[.read] = 0
        }
    }
    
    override func refresh(clearBeforeRefresh: Bool) async throws {
        filteredKeywords = persistenceRepository.loadFilteredKeywords()
        try await super.refresh(clearBeforeRefresh: clearBeforeRefresh)
    }
    
    // MARK: StandardTracker Loading Methods
    
    override func fetchPage(page: Int) async throws -> FetchResponse<Post2> {
        let result = try await feedType.getPosts(sort: postSortType, page: page, cursor: nil, limit: internetSpeed.pageSize)
        
        let filteredPosts = filter(result.posts)
        preloadImages(filteredPosts)
        return .init(items: filteredPosts, cursor: result.cursor, numFiltered: result.posts.count - filteredPosts.count)
    }
    
    override func fetchCursor(cursor: String?) async throws -> FetchResponse<Post2> {
        let result = try await feedType.getPosts(sort: postSortType, page: page, cursor: cursor, limit: internetSpeed.pageSize)
        
        let filteredPosts = filter(result.posts)
        preloadImages(filteredPosts)
        return .init(items: filteredPosts, cursor: result.cursor, numFiltered: result.posts.count - filteredPosts.count)
    }
    
    // MARK: Custom Behavior
    
    /// Changes the post sort type to the specified value and reloads the feed
    func changeSortType(to newSortType: ApiSortType, forceRefresh: Bool = false) async {
        // don't do anything if sort type not changed
        guard postSortType != newSortType || forceRefresh else {
            return
        }
        
        postSortType = newSortType
        do {
            try await refresh(clearBeforeRefresh: true)
        } catch {
            errorHandler.handle(error)
        }
    }
    
    @MainActor
    func changeFeedType(to newFeedType: TrackerFeedType) async {
//        // don't do anything if feed type not changed
//        guard feedType != newFeedType else {
//            return
//        }
//
        // always perform assignment--if account changed, feed type will look unchanged but API will be different
        feedType = newFeedType
        
        // if nominal feed type unchanged, don't refresh
        if feedType != newFeedType {
            do {
                try await refresh(clearBeforeRefresh: true)
            } catch {
                errorHandler.handle(error)
            }
        }
    }
    
    @available(
        *,
        deprecated,
        message: "Compatibility function for UserView. Should be removed and UserView refactored to use new multi-trackers."
    )
    func reset(with newPosts: [Post2]) async {
        await setItems(newPosts)
    }
    
    /// Applies a filter to all items currently in the tracker, but does **NOT** add the filter to the tracker!
    /// Use in situations where filtering is handled server-side but should be retroactively applied to the current set of posts (e.g., filtering posts from a blocked user or community)
    /// - Parameter filter: filter to apply
    func applyFilter(_ filter: PostFilter) async {
        await setItems(items.filter { shouldFilterPost($0, filters: [filter]) == nil })
    }
    
    /// Adds a filter to the tracker, removing all current posts that do not pass the filter and filtering out all future posts that do not pass the filter.
    /// Use in situations where filtering is handled client-side (e.g., filtering read posts or keywords)
    /// - Parameter newFilter: NewPostFilterReason describing the filter to apply
    func addFilter(_ newFilter: PostFilter) async {
        guard !filters.keys.contains(newFilter) else {
            assertionFailure("Cannot apply new filter (already present in filters!)")
            return
        }
        
        filters[newFilter] = 0
        await setItems(filter(items))
        
        if items.isEmpty {
            do {
                try await refresh(clearBeforeRefresh: false)
            } catch {
                errorHandler.handle(error)
            }
        }
    }
    
    func removeFilter(_ filterToRemove: PostFilter) async {
        guard filters.keys.contains(filterToRemove) else {
            assertionFailure("Cannot remove filter (not present in filters!)")
            return
        }
        
        filters.removeValue(forKey: filterToRemove)
        do {
            try await refresh(clearBeforeRefresh: true)
        } catch {
            errorHandler.handle(error)
        }
    }
    
    func getFilteredCount(for filter: PostFilter) -> Int {
        filters[filter, default: 0]
    }
    
    /// Filters a given list of posts. Updates the counts of filtered posts in `filters`
    /// - Parameter posts: list of posts to filter
    /// - Returns: list of posts with filtered posts removed
    private func filter(_ posts: [Post2]) -> [Post2] {
        var ret: [Post2] = .init()
        
        for post in posts {
            if let filterReason = shouldFilterPost(post, filters: Array(filters.keys)) {
                filters[filterReason] = filters[filterReason, default: 0] + 1
            } else {
                ret.append(post)
            }
        }
        
        return ret
    }
    
    /// Given a post, determines whether it should be filtered
    /// - Returns: the first reason according to which the post should be filtered, if applicable, or nil if the post should not be filtered
    private func shouldFilterPost(_ post: Post2, filters: [PostFilter]) -> PostFilter? {
        for filter in filters {
            switch filter {
            case .read:
                if post.isRead { return filter }
            case .keyword:
                if post.title.lowercased().contains(filteredKeywords) { return filter }
            }
        }
        return nil
    }
    
    private func preloadImages(_ newPosts: [Post2]) {
        URLSession.shared.configuration.urlCache = AppConstants.urlCache
        var imageRequests: [ImageRequest] = []
        for post in newPosts {
            // preload user and community avatars--fetching both because we don't know which we'll need, but these are super tiny
            // so it's probably not an API crime, right?
            if let communityAvatarLink = post.community.avatar {
                imageRequests.append(ImageRequest(url: communityAvatarLink.withIconSize(Int(AppConstants.smallAvatarSize * 2))))
            }
            
            if let userAvatarLink = post.creator.avatar {
                imageRequests.append(ImageRequest(url: userAvatarLink.withIconSize(Int(AppConstants.largeAvatarSize * 2))))
            }
            
            switch post.postType {
            case let .image(url):
                // images: only load the image
                imageRequests.append(ImageRequest(url: url, priority: .high))
            case let .link(url):
                // websites: load image and favicon
                if let baseURL = post.linkUrl?.host,
                   let favIconURL = URL(string: "https://www.google.com/s2/favicons?sz=64&domain=\(baseURL)") {
                    imageRequests.append(ImageRequest(url: favIconURL))
                }
                if let url {
                    imageRequests.append(ImageRequest(url: url, priority: .high))
                }
            default:
                break
            }
        }
        
        prefetcher.startPrefetching(with: imageRequests)
    }
}
