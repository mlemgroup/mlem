//
//  Post Tracker New.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-26.
//

import Dependencies
import Foundation
import Nuke
import SwiftUI

// swiftlint:disable type_body_length
// swiftlint:disable file_length
/// New post tracker built on top of the PostRepository instead of calling the API directly. Because this thing works fundamentally differently from the old one, it can't conform to FeedTracker--that's going to need a revamp down the line once everything uses nice shiny middleware models, so for now we're going to have to put up with some ugly
class PostTrackerNew: ObservableObject {
    // dependencies
    @Dependency(\.postRepository) var postRepository
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.hapticManager) var hapticManager
    
    // behavior governors
    private let shouldPerformMergeSorting: Bool
    private let internetSpeed: InternetSpeed

    // state drivers
    @Published var items: [PostModel]

    // utility
    private var ids: Set<ContentModelIdentifier> = .init(minimumCapacity: 1000)
    private(set) var isLoading: Bool = false // accessible but not published because it causes lots of bad view redraws
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
    
    // TODO: ERIC handle loading state properly
    
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
                limit: internetSpeed.pageSize
            )
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
    
    /// Loads a single post and adds it to the tracker
    /// - Parameter postId: id of the post to load
    /// - Returns: PostModel of the newly loaded post
    @discardableResult
    func loadPost(postId: Int) async throws -> PostModel {
        let newPost = try await postRepository.loadPost(postId: postId)
        await add([newPost], preload: true)
        return newPost
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
    /// Adds a given list of posts to items. Can be configured to perform filtering and preloading.
    /// - Parameters:
    ///   - newItems: list of PostModels to add
    ///   - filtering: filter to apply before adding items
    ///   - preload: true if the new post's image should be preloaded
    func add(
        _ newItems: [PostModel],
        filtering: @escaping (_: PostModel) -> Bool = { _ in true },
        preload: Bool = false
    ) {
        let accepted = dedupedItems(from: newItems.filter(filtering))
        
        if preload { preloadImages(newItems) }
        
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

    /// Determines whether the tracker should load more items
    /// NOTE: this is equivalent to the old shouldLoadContentPreciselyAfter
    @MainActor
    func shouldLoadContentAfter(after item: PostModel) -> Bool {
        guard !isLoading else { return false }

        let thresholdIndex = max(0, items.index(items.endIndex, offsetBy: AppConstants.infiniteLoadThresholdOffset))
        if thresholdIndex >= 0,
           let itemIndex = items.firstIndex(where: { $0.uid == item.uid }),
           itemIndex >= thresholdIndex {
            return true
        }

        return false
    }
    
    // MARK: - Post Management Methods
    
    /// If a post with the same id as the given post is present in the tracker, replaces it with the given post; otherwise does nothing and quietly returns.
    /// - Parameter updatedPost: PostModel representing a post already present in the tracker with a new state
    @MainActor
    func update(with updatedPost: PostModel) {
        guard let index = items.firstIndex(where: { $0.uid == updatedPost.uid }) else {
            return
        }

        items[index] = updatedPost
    }
    
    @MainActor
    func prepend(_ newPost: PostModel) {
        guard ids.insert(newPost.uid).inserted else { return }
        items.prepend(newPost)
    }
    
    @MainActor
    func removeUserPosts(from personId: Int) {
        filter {
            $0.creator.id != personId
        }
    }
    
    @MainActor
    func removeCommunityPosts(from communityId: Int) {
        filter {
            $0.community.id != communityId
        }
    }
    
    /// Takes a callback and filters out any entry that returns false
    /// Returns the number of entries removed
    @discardableResult func filter(_ callback: (PostModel) -> Bool) -> Int {
        var removedElements = 0
        
        items = items.filter {
            let filterResult = callback($0)
            
            // Remove the ID from the IDs set as well
            if !filterResult {
                ids.remove($0.uid)
                removedElements += 1
            }
            return filterResult
        }
        
        return removedElements
    }
    
    // MARK: - Interaction Methods
  
    /// Applies the given scoring operation to the given post, provided the post is present in ids. If the given operation has already been applied, it will instead send .resetVote.
    /// Performs state faking--posts will updated immediately with the predicted state of the post post-update, then updated to match the source of truth when the call returns.
    /// - Parameters:
    ///   - post: PostModel of the post to vote on
    ///   - inputOp: ScoringOperation to apply to the given post
    /// - Returns: PostModel with the updated post state (if the call fails, returns the original post model)
    @discardableResult
    func voteOnPost(post: PostModel, inputOp: ScoringOperation) async -> PostModel {
        // TODO: returning the post does sometimes cause weird unwanted state flickers when spamming interactions
        guard !isLoading else { return post }
        defer { isLoading = false }
        isLoading = true
        
        // ensure this is a valid post to vote on
        guard ids.contains(post.uid) else {
            assertionFailure("Upvote called on post not present in tracker")
            hapticManager.play(haptic: .failure, priority: .high)
            return post
        }
        
        // compute appropriate operation
        let operation = post.votes.myVote == inputOp ? ScoringOperation.resetVote : inputOp
        
        // fake state
        let stateFakedPost = PostModel(from: post, votes: post.votes.applyScoringOperation(operation: operation))
        await update(with: stateFakedPost)
        hapticManager.play(haptic: .gentleSuccess, priority: .low)
        
        // perform real upvote
        do {
            let response = try await postRepository.ratePost(postId: post.postId, operation: operation)
            await update(with: response)
            return response
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
            return post
        }
    }
    
    /// Toggles the save state of the given post. Performs state faking.
    /// - Parameter post: PostModel of the post to save
    /// - Returns: PostModel with the updated post state (if the call fails, returns the original post model)
    @discardableResult
    func toggleSave(post: PostModel) async -> PostModel {
        guard !isLoading else { return post }
        defer { isLoading = false }
        isLoading = true
        
        // ensure this is a valid post to save
        guard ids.contains(post.uid) else {
            assertionFailure("Save called on post not present in tracker")
            hapticManager.play(haptic: .failure, priority: .high)
            return post
        }
        
        let shouldSave: Bool = !post.saved
        
        // fake state
        let stateFakedPost = PostModel(from: post, saved: shouldSave)
        await update(with: stateFakedPost)
        hapticManager.play(haptic: .firmerInfo, priority: .high)
        
        // perform real save
        do {
            let response = try await postRepository.savePost(postId: post.postId, shouldSave: shouldSave)
            await update(with: response)
            return response
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
            return post
        }
    }
    
    /// Marks the given post as read (does not toggle)
    func markRead(post: PostModel) async {
        guard !isLoading else { return }
        defer { isLoading = false }
        isLoading = true
        
        // ensure this is a valid post to mark read
        guard ids.contains(post.uid) else {
            assertionFailure("markRead called on post not present in tracker")
            hapticManager.play(haptic: .failure, priority: .high)
            return
        }
        
        // fake state
        let stateFakedPost = PostModel(from: post, read: true)
        await update(with: stateFakedPost)
        
        // perform real read
        do {
            let response = try await postRepository.markRead(postId: post.postId, read: true)
            await update(with: response)
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
        }
    }
    
    func delete(post: PostModel) async {
        guard !isLoading else { return }
        defer { isLoading = false }
        isLoading = true
        
        // ensure this is a valid post to delete
        guard ids.contains(post.uid) else {
            assertionFailure("delete called on post not present in tracker")
            hapticManager.play(haptic: .failure, priority: .high)
            return
        }
        
        // TODO: state faking (should wait until APIPost is replaced with PostContentModel)
        
        do {
            hapticManager.play(haptic: .destructiveSuccess, priority: .high)
            let response = try await postRepository.deletePost(postId: post.postId, shouldDelete: true)
            await update(with: response)
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
        }
    }
    
    /// Edits the given post and updates the tracker. Only non-nil fields will be updated.
    /// - Parameters:
    ///   - post: PostModel representing the new state of the post (current state of tracker)
    @discardableResult
    func edit(
        post: PostModel,
        name: String?,
        url: String?,
        body: String?,
        nsfw: Bool?
    ) async -> PostModel {
        guard !isLoading else { return post }
        defer { isLoading = false }
        isLoading = true
        
        // ensure this is a valid post to delete
        guard ids.contains(post.uid) else {
            assertionFailure("edit called on post not present in tracker")
            hapticManager.play(haptic: .failure, priority: .high)
            return post
        }
        
        // TODO: state faking (should wait until APIPost is replaced with PostContentModel)
        
        do {
            hapticManager.play(haptic: .success, priority: .high)
            let response = try await postRepository.editPost(postId: post.postId, name: name, url: url, body: body, nsfw: nsfw)
            await update(with: response)
            return response
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
            return post
        }
    }
    
    // MARK: - Private Methods
    
    private func preloadImages(_ newPosts: [PostModel]) {
        URLSession.shared.configuration.urlCache = AppConstants.urlCache
        var imageRequests: [ImageRequest] = []
        for post in newPosts {
            // preload user and community avatars--fetching both because we don't know which we'll need, but these are super tiny
            // so it's probably not an API crime, right?
            if let communityAvatarLink = post.community.icon {
                imageRequests.append(ImageRequest(url: communityAvatarLink.withIcon64Parameters))
            }
            
            if let userAvatarLink = post.creator.avatar {
                imageRequests.append(ImageRequest(url: userAvatarLink.withIcon64Parameters))
            }
            
            switch post.postType {
            case let .image(url):
                // images: only load the image
                imageRequests.append(ImageRequest(url: url, priority: .high))
            case let .link(url):
                // websites: load image and favicon
                if let baseURL = post.post.url?.host,
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
    
    /// Filters a list of PostModels to only those PostModels not present in ids. Updates ids.
    private func dedupedItems(from newItems: [PostModel]) -> [PostModel] {
        newItems.filter { ids.insert($0.uid).inserted }
    }
}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
