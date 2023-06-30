//
//  Post Tracker.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation

class PostTracker: FeedTracker<APIPostView> {
    
    /// A method to request the tracker loads the next page of posts
    /// - Parameters:
    ///   - account: The `SavedAccount` for the logged in user
    ///   - communityId: An optional `Int` if you are retrieving posts for a specific community
    ///   - sort: The sorting type for the feed
    ///   - type: The type of feed the tracker should load
    func loadNextPage(account: SavedAccount, communityId: Int?, sort: PostSortType?, type: FeedType) async throws {
        let response = try await perform(
            GetPostsRequest(
                account: account,
                communityId: communityId,
                page: page,
                sort: sort,
                type: type,
                limit: page == 1 ? 25 : 50
            )
        )
        
        Task(priority: .background) {
            preloadImages(response.posts)
        }
    }
    
    func refresh(account: SavedAccount, communityId: Int?, sort: PostSortType?, type: FeedType) async throws {
        let response = try await refresh(
            GetPostsRequest(
                account: account,
                communityId: communityId,
                page: 1,
                sort: sort,
                type: type,
                limit: 25
            )
        )
        
        Task(priority: .background) {
            preloadImages(response.posts)
        }
    }
    
    // MARK: - Private methods
    
    private func preloadImages(_ newPosts: [APIPostView]) {
        URLSession.shared.configuration.urlCache = AppConstants.urlCache
        for post in newPosts {
            if let thumbnailUrl = post.post.thumbnailUrl {
                Task(priority: .background) {
                    await preloadSingleImage(url: thumbnailUrl)
                }
            }
            switch post.postType {
            case .image(let url):
                Task(priority: .background) {
                    await preloadSingleImage(url: url)
                }
            default:
                break
            }

        }
    }

    private func preloadSingleImage(url: URL) async {
        do {
            let request = URLRequest(url: url)
            let (data, response) = try await URLSession.shared.data(for: request)
            let cachedResponse = CachedURLResponse(response: response, data: data)
            AppConstants.urlCache.storeCachedResponse(cachedResponse, for: request)
        } catch {
            /* no action is necessary on failure here */
        }
    }
}
