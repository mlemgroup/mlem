//
//  Post Tracker New.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-26.
//

import Foundation
import Nuke
import SwiftUI
import Dependencies

/**
 New post tracker built on top of the PostRepository instead of calling the API directly. Because this thing works fundamentally differently from the old one, it can't conform to FeedTracker--that's going to need a revamp down the line once everything uses nice shiny middleware models, so for now we're going to have to put up with some ugly
 */
class PostTrackerNew: ObservableObject {
    // dependencies
    @Dependency(\.postRepository) var postRepository
    @Dependency(\.apiClient) var apiClient
    
    // behavior governors
    private let shouldPerformMergeSorting: Bool
    private let internetSpeed: InternetSpeed

    // state drivers
    @Published var items: [PostModel]

    // utility
    private var ids: Set<ContentModelIdentifier> = .init(minimumCapacity: 1000)
    private(set) var isLoading: Bool = true // accessible but not published because it causes lots of bad view redraws
    private(set) var page: Int = 1
    
    // prefetching
    private let prefetcher = ImagePrefetcher(
        pipeline: ImagePipeline.shared,
        destination: .memoryCache,
        maxConcurrentRequestCount: 40
    )
    
    init(
        shouldPerformMergeSorting: Bool = true,
        internetSpeed: InternetSpeed,
        initialItems: [PostModel] = .init()
    ) {
        self.shouldPerformMergeSorting = shouldPerformMergeSorting
        self.internetSpeed = internetSpeed
        self.items = initialItems
    }
    
    // MARK: - Loading Methods
    
    func loadNextPage(
        communityId: Int?,
        sort: PostSortType?,
        type: FeedType,
        filtering: @escaping (_: PostModel) -> Bool = { _ in true }
    ) async throws {
        let currentPage = page
        
        // retry this until we get enough items through the filter to enable autoload
        var newPosts: [PostModel] = .init()
        let numItems = items.count
        repeat {
            newPosts = try await postRepository.loadPage(
                communityId: communityId,
                page: page,
                sort: sort,
                type: type,
                limit: internetSpeed.pageSize)
            await add(newPosts, filtering: filtering)
            page += 1
        } while !newPosts.isEmpty && numItems > items.count + AppConstants.infiniteLoadThresholdOffset
        
        // so although the API kindly returns `400`/"not_logged_in" for expired
        // sessions _without_ 2FA enabled, currently once you enable 2FA on an account
        // an expired session for a call with optional authentication such as loading
        // posts returns a `200` with an empty list of data 😭
        // if we get back an empty list for page 1, chances are this session is borked and
        // the API doesn't want to tell us - so to avoid the user being confused, we'll fire
        // off an authenticated call in the background and if appropriate show the expired
        // session modal. We should be able to remove this once the API behaves as expected.
        if currentPage == 1, newPosts.isEmpty {
            try await apiClient.attemptAuthenticatedCall()
        }
        
        // don't preload filtered images
        preloadImages(newPosts.filter(filtering))
    }
    
    func refresh(
        communityId: Int?,
        sort: PostSortType?,
        feedType: FeedType,
        clearBeforeFetch: Bool = false,
        filtering: @escaping (_: PostModel) -> Bool = { _ in true }
    ) async throws {
        if clearBeforeFetch {
            await reset()
        }
        
        let newPosts = try await postRepository.loadPage(
            communityId: communityId,
            page: page,
            sort: sort,
            type: feedType
        )
        
        await reset(with: newPosts, filteredWith: filtering)
    }
    
    @MainActor
    func add(_ newItems: [PostModel], filtering: @escaping (_: PostModel) -> Bool = { _ in true }) {
        let accepted = dedupedItems(from: newItems.filter(filtering))
        if !shouldPerformMergeSorting {
            RunLoop.main.perform { [self] in
                items.append(contentsOf: accepted)
            }
            return
        }
        
        let merged = merge(arr1: items, arr2: accepted, compare: { $0.published > $1.published })
        RunLoop.main.perform { [self] in
            items = merged
        }
    }
    
    @MainActor
    private func reset(
        with newItems: [PostModel] = .init(),
        filteredWith filter: @escaping (_: PostModel) -> Bool = { _ in true }
    ) {
        page = newItems.isEmpty ? 1 : 2
        ids = .init(minimumCapacity: 1000)
        items = dedupedItems(from: newItems.filter(filter))
    }

    /**
     Determines whether the tracker should load more items
     
     NOTE: this is equivalent to the old shouldLoadContentPreciselyAfter
     */
    @MainActor func shouldLoadContentAfter(after item: PostModel) -> Bool {
        guard !isLoading else { return false }

        let thresholdIndex = max(0, items.index(items.endIndex, offsetBy: AppConstants.infiniteLoadThresholdOffset))
        if thresholdIndex >= 0,
           let itemIndex = items.firstIndex(where: { $0.id == item.id }),
           itemIndex >= thresholdIndex {
            return true
        }

        return false
    }
    
    // MARK: - Private methods
    
    private func preloadImages(_ newPosts: [PostModel]) {
        URLSession.shared.configuration.urlCache = AppConstants.urlCache
        var imageRequests: [ImageRequest] = []
        for postModel in newPosts {
            // preload user and community avatars--fetching both because we don't know which we'll need, but these are super tiny
            // so it's probably not an API crime, right?
            if let communityAvatarLink = postModel.community.icon {
                imageRequests.append(ImageRequest(url: communityAvatarLink.withIcon64Parameters))
            }
            
            if let userAvatarLink = postModel.creator.avatar {
                imageRequests.append(ImageRequest(url: userAvatarLink.withIcon64Parameters))
            }
            
            switch postModel.postType {
            case let .image(url):
                // images: only load the image
                imageRequests.append(ImageRequest(url: url, priority: .high))
            case let .link(url):
                // websites: load image and favicon
                if let baseURL = postModel.post.url?.host,
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
    }
    
    /**
     Filters a list of PostModels to only those PostModels not present in ids. Updates ids.
     */
    private func dedupedItems(from newItems: [PostModel]) -> [PostModel] {
        return newItems.filter { ids.insert($0.id).inserted }
    }
}
