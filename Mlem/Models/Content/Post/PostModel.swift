//
//  Post Model.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-26.
//

import Dependencies
import Foundation

// swiftlint:disable type_body_length
/// Internal model to represent a post
/// Note: this is just the first pass at decoupling the internal models from the API models--to avoid massive merge conflicts and an unreviewably large PR, I've kept the structure practically identical, and will slowly morph it over the course of several PRs. Eventually all of the API types that this model uses will go away and everything downstream of the repositories won't ever know there's an API at all :)
class PostModel: ContentIdentifiable, ObservableObject {
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.postRepository) var postRepository
    @Dependency(\.commentRepository) var communityRepository
    @Dependency(\.siteInformation) var siteInformation
    @Dependency(\.notifier) var notifier
    
    var postId: Int
    var post: APIPost
    var creator: UserModel
    var community: CommunityModel
    @Published var votes: VotesModel
    var commentCount: Int
    @Published var unreadCommentCount: Int
    @Published var saved: Bool
    @Published var read: Bool
    @Published var deleted: Bool
    var published: Date
    var updated: Date?
    @Published var creatorBannedFromCommunity: Bool
    var links: [LinkType]
    var purged: Bool = false
    
    var uid: ContentModelIdentifier { .init(contentType: .post, contentId: postId) }
    
    // prevents a voting operation from ocurring while another is ocurring
    var voting: Bool = false
    
    /// Creates a PostModel from an APIPostView
    /// - Parameter apiPostView: APIPostView to create a PostModel representation of
    init(from apiPostView: APIPostView) {
        self.postId = apiPostView.post.id
        self.post = apiPostView.post
        self.creator = UserModel(from: apiPostView.creator)
        creator.blocked = apiPostView.creatorBlocked
        self.community = CommunityModel(from: apiPostView.community, subscribed: apiPostView.subscribed.isSubscribed)
        community.blocked = false
        self.votes = VotesModel(from: apiPostView.counts, myVote: apiPostView.myVote)
        self.commentCount = apiPostView.counts.comments
        self.unreadCommentCount = apiPostView.unreadComments
        self.saved = apiPostView.saved
        self.read = apiPostView.read
        self.deleted = apiPostView.post.deleted
        self.published = apiPostView.post.published
        self.updated = apiPostView.post.updated
        self.creatorBannedFromCommunity = apiPostView.creatorBannedFromCommunity
        
        self.links = PostModel.parseLinks(from: post.body)
    }
    
    /// Creates a PostModel from another PostModel. Any provided field values will override values in post.
    /// - Parameters:
    ///   - other: PostModel to copy
    ///   - postId: overriden post id
    ///   - post: overriden post content
    ///   - creator: overriden post creator
    ///   - community: overriden post community
    ///   - votes: overriden votes
    ///   - numReplies: overriden number of replies
    ///   - saved: overriden saved status
    ///   - read: overriden read status
    ///   - published: overriden published time
    init(
        from other: PostModel,
        postId: Int? = nil,
        post: APIPost? = nil,
        creator: UserModel? = nil,
        community: CommunityModel? = nil,
        votes: VotesModel? = nil,
        commentCount: Int? = nil,
        unreadCommentCount: Int? = nil,
        saved: Bool? = nil,
        read: Bool? = nil,
        deleted: Bool? = nil,
        published: Date? = nil,
        updated: Date? = nil,
        creatorBannedFromCommunity: Bool? = nil
    ) {
        self.postId = postId ?? other.postId
        self.post = post ?? other.post
        self.creator = creator ?? other.creator
        self.community = community ?? other.community
        self.votes = votes ?? other.votes
        self.commentCount = commentCount ?? other.commentCount
        self.unreadCommentCount = unreadCommentCount ?? other.unreadCommentCount
        self.saved = saved ?? other.saved
        self.read = read ?? other.read
        self.deleted = deleted ?? other.deleted
        self.published = published ?? other.published
        self.updated = updated ?? other.updated
        self.creatorBannedFromCommunity = creatorBannedFromCommunity ?? other.creatorBannedFromCommunity
        
        self.links = PostModel.parseLinks(from: self.post.body)
    }
    
    // MARK: Main Actor State Change Methods
    
    @MainActor func reinit(from postModel: PostModel) {
        postId = postModel.postId
        post = postModel.post
        creator = postModel.creator
        community = postModel.community
        votes = postModel.votes
        commentCount = postModel.commentCount
        unreadCommentCount = postModel.unreadCommentCount
        saved = postModel.saved
        read = postModel.read
        published = postModel.published
        updated = postModel.updated
        creatorBannedFromCommunity = postModel.creatorBannedFromCommunity
        
        links = postModel.links
    }
    
    @MainActor
    func setVotes(_ newVotes: VotesModel) {
        votes = newVotes
    }
    
    @MainActor
    func setRead(_ newRead: Bool) {
        read = newRead
    }
    
    @MainActor
    func setSaved(_ newSaved: Bool) {
        saved = newSaved
    }
    
    @MainActor
    func setDeleted(_ newDeleted: Bool) {
        deleted = newDeleted
    }
    
    @MainActor
    func setCreatorBannedFromCommunity(_ newCreatorBannedFromCommunity: Bool) {
        creatorBannedFromCommunity = newCreatorBannedFromCommunity
    }
    
    // MARK: Interaction Methods
    
    func vote(inputOp: ScoringOperation) async {
        hapticManager.play(haptic: .lightSuccess, priority: .low)
        let operation = votes.myVote == inputOp ? ScoringOperation.resetVote : inputOp
        
        // state fake
        let original: PostModel = .init(from: self)
        await setVotes(votes.applyScoringOperation(operation: operation))
        await setRead(true)
        
        // API call
        do {
            let updatedPost = try await postRepository.ratePost(postId: postId, operation: operation)
            await reinit(from: updatedPost)
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
            await reinit(from: original)
        }
    }
    
    func toggleUpvote() async { await vote(inputOp: .upvote) }
    func toggleDownvote() async { await vote(inputOp: .downvote) }
    
    func markRead(_ newRead: Bool) async {
        // state fake
        let original: PostModel = .init(from: self)
        await setRead(newRead)
        
        // API call
        do {
            let updatedPost = try await postRepository.markRead(post: self, read: newRead)
            await reinit(from: updatedPost)
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
            await reinit(from: original)
        }
    }
    
    func toggleSave() async {
        hapticManager.play(haptic: .success, priority: .low)
        
        let shouldSave: Bool = !saved
        let upvoteOnSave = UserDefaults.standard.bool(forKey: "upvoteOnSave")
        
        // state fake
        let original: PostModel = .init(from: self)
        await setSaved(shouldSave)
        await setRead(true)
        if shouldSave, upvoteOnSave, votes.myVote != .upvote {
            await setVotes(votes.applyScoringOperation(operation: .upvote))
        }
        
        // API call
        do {
            let saveResponse = try await postRepository.savePost(postId: postId, shouldSave: shouldSave)
            
            if shouldSave, upvoteOnSave {
                let voteResponse = try await postRepository.ratePost(postId: postId, operation: .upvote)
                await reinit(from: voteResponse)
            } else {
                await reinit(from: saveResponse)
            }
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
            await reinit(from: original)
        }
    }
    
    func edit(
        name: String?,
        url: String?,
        body: String?,
        nsfw: Bool?
    ) async {
        // no need to state fake because editor spins until call completes
        do {
            hapticManager.play(haptic: .success, priority: .high)
            let response = try await postRepository.editPost(postId: postId, name: name, url: url, body: body, nsfw: nsfw)
            await reinit(from: response)
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
        }
    }
    
    func toggleFeatured(featureType: APIPostFeatureType) async {
        // no state fake because it would be extremely tedious for little value add now but very easy to do post-2.0
        do {
            let response = try await apiClient.featurePost(id: postId, shouldFeature: !post.featuredCommunity, featureType: featureType)
            await reinit(from: PostModel(from: response))
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
        }
    }
    
    func toggleLocked() async {
        // no state fake because it would be extremely tedious for little value add now but very easy to do post-2.0
        do {
            let response = try await apiClient.lockPost(id: postId, shouldLock: !post.locked)
            await reinit(from: PostModel(from: response))
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
        }
    }
    
    func delete() async {
        // state fake
        let original: PostModel = .init(from: self)
        await setDeleted(true)
        
        // API call
        do {
            let deletedResponse = try await postRepository.deletePost(postId: postId, shouldDelete: true)
            await reinit(from: deletedResponse)
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
            await reinit(from: original)
        }
    }
    
    func toggleRemove(reason: String?) async {
        // no need to state fake because removal masked by sheet
        do {
            let response = try await apiClient.removePost(
                id: postId,
                shouldRemove: !post.removed,
                reason: reason
            )
            await reinit(from: response)
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
        }
    }
    
    func purge(reason: String?) async -> Bool {
        DispatchQueue.main.async {
            self.purged = true
        }
        do {
            let response = try await apiClient.purgePost(id: postId, reason: reason)
            if !response.success {
                throw APIClientError.unexpectedResponse
            }
            return true
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
            DispatchQueue.main.async {
                self.purged = false
            }
        }
        return false
    }
    
    // MARK: Utility Methods
    
    var postType: PostType {
        // post with URL: either image or link
        if let postUrl = post.linkUrl {
            // if image, return image link, otherwise return thumbnail
            return postUrl.isImage ? .image(postUrl) : .link(post.thumbnailImageUrl)
        }

        // otherwise text, but post.body needs to be present, even if it's an empty string
        if let postBody = post.body {
            return .text(postBody)
        }

        return .titleOnly
    }
    
    static func parseLinks(from body: String?) -> [LinkType] {
        guard let body else {
            return []
        }
        return body.parseLinks()
    }
}

extension PostModel: Hashable {
    /// Hashes all fields for which state changes should trigger view updates.
    func hash(into hasher: inout Hasher) {
        hasher.combine(post.id)
        hasher.combine(votes)
        hasher.combine(saved)
        hasher.combine(read)
        hasher.combine(post.updated)
        hasher.combine(unreadCommentCount)
    }
}

extension PostModel: Identifiable {
    var id: Int { hashValue }
}

extension PostModel: Equatable {
    static func == (lhs: PostModel, rhs: PostModel) -> Bool {
        lhs.id == rhs.id
    }
}

// swiftlint:enable type_body_length
