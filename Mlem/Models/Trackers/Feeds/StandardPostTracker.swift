//
//  StandardPostTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-04.
//

import Dependencies
import Foundation
import Nuke

/// Enumeration of criteria on which to filter a post
enum PostFilter: Hashable {
    /// Post is filtered because it was read
    case read
    
    /// Post is filtered because it contains a blocked keyword
    case keyword
    
    /// Post is filtered because the user is blocked (associated value is user id)
    case blockedUser(Int)
    
    /// Post is filtered because community is blocked (associated value is community id)
    case blockedCommunity(Int)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .read:
            hasher.combine("read")
        case .keyword:
            hasher.combine("keyword")
        case let .blockedUser(userId):
            hasher.combine("blockedUser")
            hasher.combine(userId)
        case let .blockedCommunity(communityId):
            hasher.combine("blockedCommunity")
            hasher.combine(communityId)
        }
    }
}

/// Post tracker for use with single feeds. Supports all post sorting types, but is not suitable for multi-feed use.
class StandardPostTracker: StandardTracker<PostModel> {
    @Dependency(\.postRepository) var postRepository
    @Dependency(\.personRepository) var personRepository
    @Dependency(\.persistenceRepository) var persistenceRepository
    @Dependency(\.siteInformation) var siteInformation
    @Dependency(\.apiClient) var apiClient
    
    // TODO: ERIC keyword filters could be more elegant
    var filteredKeywords: [String]
    
    var feedType: FeedType
    private(set) var postSortType: PostSortType
    private var filters: [PostFilter: Int]
    
    // prefetching
    private let prefetcher = ImagePrefetcher(
        pipeline: ImagePipeline.shared,
        destination: .memoryCache,
        maxConcurrentRequestCount: 40
    )
    
    init(internetSpeed: InternetSpeed, sortType: PostSortType, showReadPosts: Bool, feedType: FeedType) {
        @Dependency(\.persistenceRepository) var persistenceRepository
        
        assert(feedType != .saved, "Cannot create StandardPostTracker for saved feed!")
        
        self.feedType = feedType
        self.postSortType = sortType
        
        self.filteredKeywords = persistenceRepository.loadFilteredKeywords()
        self.filters = [.keyword: 0]
        if !showReadPosts {
            filters[.read] = 0
        }
        
        super.init(internetSpeed: internetSpeed)
    }
    
    override func refresh(clearBeforeRefresh: Bool) async throws {
        filteredKeywords = persistenceRepository.loadFilteredKeywords()
        try await super.refresh(clearBeforeRefresh: clearBeforeRefresh)
    }
    
    // MARK: StandardTracker Loading Methods
    
    override func fetchPage(page: Int) async throws -> FetchResponse<PostModel> {
        let (items, cursor) = try await postRepository.loadPage(
            communityId: feedType.communityId,
            page: page,
            cursor: nil,
            sort: postSortType,
            type: feedType.toApiListingType,
            limit: internetSpeed.pageSize
        )
        
        let filteredItems = filter(items)
        preloadImages(filteredItems)
        return .init(items: filteredItems, cursor: cursor, numFiltered: items.count - filteredItems.count)
    }
    
    override func fetchCursor(cursor: String?) async throws -> FetchResponse<PostModel> {
        let (items, cursor) = try await postRepository.loadPage(
            communityId: feedType.communityId,
            page: page,
            cursor: cursor,
            sort: postSortType,
            type: feedType.toApiListingType,
            limit: internetSpeed.pageSize
        )
        
        let filteredItems = filter(items)
        preloadImages(filteredItems)
        return .init(items: filteredItems, cursor: cursor, numFiltered: items.count - filteredItems.count)
    }
    
    // MARK: Custom Behavior
    
    /// Changes the post sort type to the specified value and reloads the feed
    func changeSortType(to newSortType: PostSortType, forceRefresh: Bool = false) async {
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
    func changeFeedType(to newFeedType: FeedType) async {
        // don't do anything if feed type not changed
        guard feedType != newFeedType else {
            return
        }
        
        feedType = newFeedType
        do {
            try await refresh(clearBeforeRefresh: true)
        } catch {
            errorHandler.handle(error)
        }
    }
    
    @available(
        *,
        deprecated,
        message: "Compatibility function for UserView. Should be removed and UserView refactored to use new multi-trackers."
    )
    func reset(with newPosts: [PostModel]) async {
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
    private func filter(_ posts: [PostModel]) -> [PostModel] {
        var ret: [PostModel] = .init()
        
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
    private func shouldFilterPost(_ postModel: PostModel, filters: [PostFilter]) -> PostFilter? {
        for filter in filters {
            switch filter {
            case .read:
                if postModel.read { return filter }
            case .keyword:
                if postModel.post.name.lowercased().contains(filteredKeywords) { return filter }
            case let .blockedUser(userId):
                if postModel.creator.userId == userId { return filter }
            case let .blockedCommunity(communityId):
                if postModel.community.communityId == communityId { return filter }
            }
        }
        return nil
    }
    
    private func preloadImages(_ newPosts: [PostModel]) {
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
                if let baseURL = post.post.linkUrl?.host,
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
