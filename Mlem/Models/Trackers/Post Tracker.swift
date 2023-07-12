//
//  Post Tracker.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation
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
        let currentPage = page
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

        // so although the API kindly returns `400`/"not_logged_in" for expired
        // sessions _without_ 2FA enabled, currently once you enable 2FA on an account
        // an expired session for a call with optional authentication such as loading
        // posts returns a `200` with an empty list of data 😭
        // if we get back an empty list for page 1, chances are this session is borked and
        // the API doesn't want to tell us - so to avoid the user being confused, we'll fire
        // off an authenticated call in the background and if appropriate show the expired
        // session modal. We should be able to remove this once the API behaves as expected.
        if currentPage == 1 && response.posts.isEmpty {
            try await attemptAuthenticatedCall(with: account)
        }
        
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
                imageRequests.append(ImageRequest(url: communityAvatarLink.withIcon64Parameters))
            }

            if let userAvatarLink = postView.creator.avatar {
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
    
    func removePosts(from personId: Int) {
        filter({
            return $0.creator.id != personId
        })
    }
    
    private func attemptAuthenticatedCall(with account: SavedAccount) async throws {
        let request = GetPrivateMessagesRequest(
            account: account,
            page: 1,
            limit: 1
        )
        
        do {
            try await APIClient().perform(request: request)
        } catch {
            // we're only interested in throwing for invalid sessions here...
            if case APIClientError.invalidSession = error {
                throw error
            }
        }
    }
}
