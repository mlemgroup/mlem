//
//  Comment Model.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-30.
//

import Foundation

/**
 Internal model to drive view state.
 
 NOTE: This is a very early implementation of this built to support instant vote feedback. It still uses lots of raw API types underneath--those all need analagous models built to support full decoupling of internal types and API types--and it's built to be an easy drag-and-drop replacement for APICommentView in most situations
 */
struct CommentModel: Hashable {
    // core info
    let comment: APIComment
    let creator: APIPerson
    let post: APIPost
    let community: APICommunity
    
    // metadata
    let votes: VotesModel
    let numReplies: Int
    let published: Date
    let updated: Date?
    let saved: Bool
    
    // init from API type
    init(from commentView: APICommentView) {
        self.comment = commentView.comment
        self.creator = commentView.creator
        self.post = commentView.post
        self.community = commentView.community
        self.votes = VotesModel(from: commentView.counts, myVote: commentView.myVote)
        self.numReplies = commentView.counts.childCount
        self.published = commentView.comment.published
        self.updated = commentView.comment.updated
        self.saved = commentView.saved
    }
    
    init(comment: APIComment,
         creator: APIPerson,
         post: APIPost,
         community: APICommunity,
         votes: VotesModel,
         numReplies: Int,
         published: Date,
         updated: Date?,
         saved: Bool) {
        self.comment = comment
        self.creator = creator
        self.post = post
        self.community = community
        self.votes = votes
        self.numReplies = numReplies
        self.published = published
        self.updated = updated
        self.saved = saved
    }
    
    // hashable compliance
    func hash(into hasher: inout Hasher) {
        hasher.combine(comment.id)
        hasher.combine(votes)
        hasher.combine(updated)
        hasher.combine(saved)
    }
}
