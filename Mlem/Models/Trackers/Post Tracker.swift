//
//  Post Tracker.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation
import SwiftUI
import Nuke

class PostTracker: FeedTracker<APIPostView> {

    private let prefetcher = ImagePrefetcher(pipeline: ImagePipeline.shared,
                                             destination: .memoryCache,
                                             maxConcurrentRequestCount: 40)

    /// A method to request the tracker loads the next page of posts
    /// - Parameters:
    ///   - account: The `SavedAccount` for the logged in user
    ///   - communityId: An optional `Int` if you are retrieving posts for a specific community
    ///   - sort: The sorting type for the feed
    ///   - type: The type of feed the tracker should load
    func loadNextPage(
        account: SavedAccount,
        communityId: Int?,
        sort: PostSortType?,
        type: FeedType,
        filtering: @escaping (_: APIPostView) -> Bool = { _ in true}
    ) async throws {
        let response = try await perform(
            GetPostsRequest(
                account: account,
                communityId: communityId,
                page: page,
                sort: sort,
                type: type,
                limit: page == 1 ? 25 : 50
            ),
            filtering: filtering
        )

        preloadImages(response.posts)
    }

    func refresh(
        account: SavedAccount,
        communityId: Int?,
        sort: PostSortType?,
        type: FeedType,
        filtering: @escaping (_: APIPostView) -> Bool = { _ in true}
    ) async throws {
        let response = try await refresh(
            GetPostsRequest(
                account: account,
                communityId: communityId,
                page: 1,
                sort: sort,
                type: type,
                limit: 25
            ),
            filtering: filtering
        )

        Task(priority: .background) {
            preloadImages(response.posts)
        }
    }

    // MARK: - Private methods

    private func preloadImages(_ newPosts: [APIPostView]) {
        URLSession.shared.configuration.urlCache = AppConstants.urlCache
        var imageRequests: [ImageRequest] = []
        for postView in newPosts {
            // preload user and community avatars--fetching both because we don't know which we'll need, but these are super tiny
            // so it's probably not an API crime, right?
            if let communityAvatarLink = postView.community.icon {
                imageRequests.append(ImageRequest(url: communityAvatarLink.withIcon32Parameters))
                imageRequests.append(ImageRequest(url: communityAvatarLink.withIcon64Parameters))
            }

            if let userAvatarLink = postView.creator.avatar {
                imageRequests.append(ImageRequest(url: userAvatarLink.withIcon32Parameters))
                imageRequests.append(ImageRequest(url: userAvatarLink.withIcon64Parameters))
            }

            switch postView.postType {
            case .image(let url):
                // images: only load the image
                imageRequests.append(ImageRequest(url: url, priority: .high))
            case .link(let url):
                // websites: load image and favicon
                if let baseURL = postView.post.url?.host,
                   let favIconURL = URL(string: "https://www.google.com/s2/favicons?sz=64&domain=\(baseURL)") {
                    imageRequests.append(ImageRequest(url: favIconURL))
                }
                if let url = url {
                    imageRequests.append(ImageRequest(url: url, priority: .high))
                }
            default:
                break
            }

        }

        prefetcher.startPrefetching(with: imageRequests)
    }
}
