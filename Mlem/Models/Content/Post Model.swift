//
//  Post Model.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-26.
//

import Foundation

/// Internal model to represent a post
/// Note: this is just the first pass at decoupling the internal models from the API models--to avoid massive merge conflicts and an unreviewably large PR, I've kept the structure practically identical, and will slowly morph it over the course of several PRs. Eventually all of the API types that this model uses will go away and everything downstream of the repositories won't ever know there's an API at all :)
struct PostModel {
    let postId: Int
    let post: APIPost
    let creator: APIPerson
    let community: APICommunity
    var votes: VotesModel
    let numReplies: Int
    let saved: Bool
    let read: Bool
    let published: Date
    
    var uid: ContentModelIdentifier { .init(contentType: .post, contentId: postId) }
    
    /// Creates a PostModel from an APIPostView
    /// - Parameter apiPostView: APIPostView to create a PostModel representation of
    init(from apiPostView: APIPostView) {
        self.postId = apiPostView.post.id
        self.post = apiPostView.post
        self.creator = apiPostView.creator
        self.community = apiPostView.community
        self.votes = VotesModel(from: apiPostView.counts, myVote: apiPostView.myVote)
        self.numReplies = apiPostView.counts.comments
        self.saved = apiPostView.saved
        self.read = apiPostView.read
        self.published = apiPostView.published
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
        creator: APIPerson? = nil,
        community: APICommunity? = nil,
        votes: VotesModel? = nil,
        numReplies: Int? = nil,
        saved: Bool? = nil,
        read: Bool? = nil,
        published: Date? = nil
    ) {
        self.postId = postId ?? other.postId
        self.post = post ?? other.post
        self.creator = creator ?? other.creator
        self.community = community ?? other.community
        self.votes = votes ?? other.votes
        self.numReplies = numReplies ?? other.numReplies
        self.saved = saved ?? other.saved
        self.read = read ?? other.read
        self.published = published ?? other.published
    }
    
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
}

extension PostModel: Identifiable {
    var id: Int { hashValue }
}

extension PostModel: Hashable {
    /// Hashes all fields for which state changes should trigger view updates.
    func hash(into hasher: inout Hasher) {
        hasher.combine(post.id)
        hasher.combine(votes)
        hasher.combine(saved)
        hasher.combine(read)
        hasher.combine(post.updated)
    }
}
