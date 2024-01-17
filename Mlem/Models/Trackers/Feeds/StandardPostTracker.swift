//
//  StandardPostTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-04.
//

import Dependencies
import Foundation
import Nuke

// TODO:
// - re-enable hidden item counts

/// Post tracker for use with single feeds. Supports all post sorting types, but is not suitable for multi-feed use.
class StandardPostTracker: StandardTracker<PostModel> {
    @Dependency(\.postRepository) var postRepository
    
    var unreadOnly: Bool
    var feedType: NewFeedType
    private(set) var postSortType: PostSortType
    
    // prefetching
    private let prefetcher = ImagePrefetcher(
        pipeline: ImagePipeline.shared,
        destination: .memoryCache,
        maxConcurrentRequestCount: 40
    )
    
    init(internetSpeed: InternetSpeed, sortType: PostSortType, unreadOnly: Bool, feedType: NewFeedType) {
        self.unreadOnly = unreadOnly
        self.feedType = feedType
        self.postSortType = sortType
        
        super.init(internetSpeed: internetSpeed)
    }
    
    override func fetchPage(page: Int) async throws -> (items: [PostModel], cursor: String?) {
        // TODO: ERIC migrate repository to use "items"
        let (items, cursor) = try await postRepository.loadPage(
            communityId: nil,
            page: page,
            cursor: nil,
            sort: postSortType,
            type: feedType.toLegacyFeedType,
            limit: internetSpeed.pageSize
        )
        preloadImages(items)
        return (items, cursor)
    }
    
    override func fetchCursor(cursor: String?) async throws -> (items: [PostModel], cursor: String?) {
        // TODO: ERIC migrate repository to use "items"
        let (items, cursor) = try await postRepository.loadPage(
            communityId: nil,
            page: page,
            cursor: cursor,
            sort: postSortType,
            type: feedType.toLegacyFeedType,
            limit: internetSpeed.pageSize
        )
        preloadImages(items)
        return (items, cursor)
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
