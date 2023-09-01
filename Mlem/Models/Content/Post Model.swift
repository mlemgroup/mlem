//
//  Post Model.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-26.
//

import Foundation

/**
 Internal model to represent a post
 
 Note: this is just the first pass at decoupling the internal models from the API models--to avoid massive merge conflicts and an unreviewably large PR, I've kept the structure practically identical, and will slowly morph it over the course of several PRs. Eventually all of the API types that this model uses will go away and everything downstream of the repositories won't ever know there's an API at all :)
 */
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

    /**
     Creates a PostModel from an APIPostView
     */
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
    
    /**
     Creates a PostModel from another PostModel. Any provided field values will override values in post.
     */
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
        if let postUrl = post.url {
            // if image, return image link, otherwise return thumbnail
            return postUrl.isImage ? .image(postUrl) : .link(post.thumbnailUrl)
        }

        // otherwise text, but post.body needs to be present, even if it's an empty string
        if let postBody = post.body {
            return .text(postBody)
        }

        return .titleOnly
    }
}

extension PostModel: Identifiable {
    /**
     Identifies this post as a distinct Lemmy identity. This will consider two PostModels with the same postId as identical, so if you need to trigger view updates when things like votes or save status changes, explicitly use the hash value as defined below
     */
    var id: ContentModelIdentifier { .init(contentType: .post, contentId: postId) }
}

extension PostModel: Hashable {
    /**
     Hashes all fields for which state changes should trigger view updates.
     */
    func hash(into hasher: inout Hasher) {
        hasher.combine(post.id)
        hasher.combine(votes)
        hasher.combine(saved)
        hasher.combine(read)
        hasher.combine(post.updated)
    }
}

// TODO: ERIC deprecate all this
extension PostModel: APIContentViewProtocol {
    var counts: BridgeContentAggregatesModel {
        BridgeContentAggregatesModel(from: self)
    }
    
    var myVote: ScoringOperation? {
        get {
            votes.myVote
        }
        set {
            votes.myVote = newValue ?? .resetVote
        }
    }
    
    typealias AggregatesType = BridgeContentAggregatesModel
}

struct BridgeContentAggregatesModel: APIContentAggregatesProtocol {
    var score: Int
    
    var upvotes: Int
    
    var downvotes: Int
    
    var published: Date
    
    var comments: Int
    
    init(from post: PostModel) {
        self.score = post.votes.total
        self.upvotes = post.votes.upvotes
        self.downvotes = post.votes.downvotes
        self.published = post.published
        self.comments = post.numReplies
    }
}
