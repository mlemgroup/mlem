//
//  StandardPostTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-04.
//

import Dependencies
import Foundation
import Nuke

/// Enumeration of reasons a post could be filtered
enum NewPostFilterReason: Hashable {
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
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    // TODO: ERIC keyword filters could be more elegant
    var filteredKeywords: [String]
    
    var feedType: NewFeedType
    private(set) var postSortType: PostSortType
    private var filters: [NewPostFilterReason: Int]
    
    // prefetching
    private let prefetcher = ImagePrefetcher(
        pipeline: ImagePipeline.shared,
        destination: .memoryCache,
        maxConcurrentRequestCount: 40
    )
    
    init(internetSpeed: InternetSpeed, sortType: PostSortType, showReadPosts: Bool, feedType: NewFeedType) {
        @Dependency(\.persistenceRepository) var persistenceRepository
        
        self.feedType = feedType
        self.postSortType = sortType
        
        self.filteredKeywords = persistenceRepository.loadFilteredKeywords()
        self.filters = [.keyword: 0]
        if !showReadPosts {
            print("hiding read posts")
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
        // TODO: ERIC migrate repository to use "items"
        let (items, cursor) = try await postRepository.loadPage(
            communityId: nil,
            page: page,
            cursor: nil,
            sort: postSortType,
            type: feedType.toLegacyFeedType,
            limit: internetSpeed.pageSize
        )
        
        let filteredItems = filter(items)
        preloadImages(filteredItems)
        return .init(items: filteredItems, cursor: cursor, numFiltered: items.count - filteredItems.count)
    }
    
    override func fetchCursor(cursor: String?) async throws -> FetchResponse<PostModel> {
        // TODO: ERIC migrate repository to use "items"
        let (items, cursor) = try await postRepository.loadPage(
            communityId: nil,
            page: page,
            cursor: cursor,
            sort: postSortType,
            type: feedType.toLegacyFeedType,
            limit: internetSpeed.pageSize
        )
        
        let filteredItems = filter(items)
        preloadImages(filteredItems)
        return .init(items: filteredItems, cursor: cursor, numFiltered: items.count - filteredItems.count)
    }
    
    // MARK: Custom Behavior
    
    func applyFilter(_ newFilter: NewPostFilterReason) async {
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
    
    func removeFilter(_ filterToRemove: NewPostFilterReason) async {
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
    
    /// Filters a given list of posts. Updates the counts of filtered posts in `filters`
    /// - Parameter posts: list of posts to filter
    /// - Returns: list of posts with filtered posts removed
    private func filter(_ posts: [PostModel]) -> [PostModel] {
        var ret: [PostModel] = .init()
        
        for post in posts {
            if let filterReason = shouldFilterPost(post) {
                filters[filterReason] = filters[filterReason, default: 0] + 1
            } else {
                ret.append(post)
            }
        }
        
        return ret
    }
    
    /// Given a post, determines whether it should be filtered
    /// - Returns: the first reason according to which the post should be filtered, if applicable, or nil if the post should not be filtered
    private func shouldFilterPost(_ postModel: PostModel) -> NewPostFilterReason? {
        for filter in filters.keys {
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
