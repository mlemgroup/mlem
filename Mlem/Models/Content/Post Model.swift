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
    let votes: VotesModel
    let numReplies: Int
    let saved: Bool
    let read: Bool
    let published: Date

    /**
     Creates a PostModel from an APIPostView
     */
    init(from apiPostView: APIPostView) {
        self.postId = apiPostView.id
        self.post = apiPostView.post
        self.creator = apiPostView.creator
        self.community = apiPostView.community
        self.votes = VotesModel(from: apiPostView.counts, myVote: apiPostView.myVote)
        self.numReplies = apiPostView.counts.comments
        self.saved = apiPostView.saved
        self.read = apiPostView.read
        self.published = apiPostView.published
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
