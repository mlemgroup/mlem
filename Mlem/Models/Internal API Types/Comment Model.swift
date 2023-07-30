//
//  Comment Model.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-30.
//

import Foundation

/**
 Internal model to drive view state.
 
 NOTE: This is a very early implementation of this built to support instant vote feedback. It still uses lots of raw API types underneath--those all need analagous models built to support full decoupling of internal types and API types--and it's built to be an easy drag-and-drop replacement for APICommentView in most situations. There is therefore a lot of duplicated information right now--e.g., the deleted status exists both at the top level and within the comment. Long-term APIComment will be replaced by a much leaner struct that contains nothing but the actual content of the comment, or perhaps removed altogether.
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
    let deleted: Bool
    
    /**
     Standard initializer
     */
    init(comment: APIComment,
         creator: APIPerson,
         post: APIPost,
         community: APICommunity,
         votes: VotesModel,
         numReplies: Int,
         published: Date,
         updated: Date?,
         saved: Bool,
         deleted: Bool) {
        self.comment = comment
        self.creator = creator
        self.post = post
        self.community = community
        self.votes = votes
        self.numReplies = numReplies
        self.published = published
        self.updated = updated
        self.saved = saved
        self.deleted = deleted
    }
    
    /**
     Initialize from an API type
     */
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
        self.deleted = commentView.comment.deleted
    }
    
    /**
     Copy constructor with overrides--this lets you easily create another struct with *almost* everything the same. Any optional field passed in will override the value in commentModel.
     */
    init(from commentModel: CommentModel,
         comment: APIComment? = nil,
         creator: APIPerson? = nil,
         post: APIPost? = nil,
         community: APICommunity? = nil,
         votes: VotesModel? = nil,
         numReplies: Int? = nil,
         published: Date? = nil,
         updated: Date? = nil,
         saved: Bool? = nil,
         deleted: Bool? = nil) {
        self.comment = comment ?? commentModel.comment
        self.creator = creator ?? commentModel.creator
        self.post = post ?? commentModel.post
        self.community = community ?? commentModel.community
        self.votes = votes ?? commentModel.votes
        self.numReplies = numReplies ?? commentModel.numReplies
        self.published = published ?? commentModel.published
        self.updated = updated ?? commentModel.updated
        self.saved = saved ?? commentModel.saved
        self.deleted = deleted ?? commentModel.deleted
    }
    
    // hashable compliance. Hashes the id and all fields that, if changed, should prompt a state update
    func hash(into hasher: inout Hasher) {
        hasher.combine(comment.id)
        hasher.combine(votes)
        hasher.combine(updated)
        hasher.combine(saved)
        hasher.combine(deleted)
    }
}
