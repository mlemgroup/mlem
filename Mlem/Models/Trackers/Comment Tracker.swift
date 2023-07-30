//
//  Comment Tracker.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation
import Dependencies

class CommentTracker: ObservableObject {
    
    @Dependency(\.commentRepository) var commentRepository
    @Dependency(\.errorHandler) var errorHandler
    
    @Published var comments: [HierarchicalComment] = .init()
    
    private var ids: Set<Int> = .init()
    
    // when this is true, all interaction calls will be rejected
    private var isUpdatingState: Bool = false
    
    /**
     Votes on a comment tracked by this tracker
     */
    @MainActor
    func voteOnComment(hierarchicalComment: HierarchicalComment, inputOp: ScoringOperation) async {
        
        guard !isUpdatingState else { return }
        defer { isUpdatingState = false }
        isUpdatingState = true
        
        // update with fake state
        let operation = hierarchicalComment.commentModel.votes.myVote == inputOp ? ScoringOperation.resetVote : inputOp
        comments.update(with: CommentModel(from: hierarchicalComment.commentModel,
                                           votes: hierarchicalComment.commentModel.votes.applyScoringOperation(operation: operation)))
        
        // perform the vote and upate with server state
        do {
            let updatedComment = try await commentRepository.voteOnComment(id: hierarchicalComment.commentModel.comment.id,
                                                                           vote: operation)
            comments.update(with: CommentModel(from: updatedComment))
        } catch {
            // if we failed, revert to the previous state
            comments.update(with: hierarchicalComment.commentModel)
            errorHandler.handle(.init(underlyingError: error))
        }
    }
    
    /**
     Toggles the current saved status of a given comment tracked by this tracker
     */
    @MainActor
    func toggleCommentSaved(hierarchicalComment: HierarchicalComment) async {
        
        guard !isUpdatingState else { return }
        defer { isUpdatingState = false }
        isUpdatingState = true
        
        // update with fake state
        comments.update(with: CommentModel(from: hierarchicalComment.commentModel,
                                           saved: !hierarchicalComment.commentModel.saved))
        
        // perform the save and update with server state
        do {
            let updatedComment = try await commentRepository.saveComment(id: hierarchicalComment.commentModel.comment.id,
                                                                         shouldSave: !hierarchicalComment.commentModel.saved)
            comments.update(with: updatedComment.commentModel)
        } catch {
            // if we failed, revert to previous state
            comments.update(with: hierarchicalComment.commentModel)
            errorHandler.handle(.init(underlyingError: error))
        }
    }
    
    @MainActor
    func deleteComment(hierarchicalComment: HierarchicalComment) async {
        
        guard !isUpdatingState else { return }
        defer { isUpdatingState = false }
        isUpdatingState = true
        
        // update with fake state
        comments.update(with: CommentModel(from: hierarchicalComment.commentModel,
                                           deleted: true))
        
        // perform the delete and update with server state
        // TODO: enable undeleting
        do {
            let updatedComment = try await commentRepository.deleteComment(id: hierarchicalComment.commentId,
                                                                           shouldDelete: true)
            comments.update(with: updatedComment.commentModel)
        } catch {
            comments.update(with: hierarchicalComment.commentModel)
            errorHandler.handle(.init(underlyingError: error))
        }
    }
    
    /// A method to add new comments into the tracker, duplicate comments will be rejected
    func add(_ newComments: [HierarchicalComment]) {
        let accepted = newComments.filter { ids.insert($0.commentModel.comment.id).inserted }
        comments.append(contentsOf: accepted)
    }
    
    // Takes a callback and fillters out any entry that returns false
    //
    // Returns the number of entries removed
    @discardableResult func filter(_ callback: (HierarchicalComment) -> Bool) -> Int {
        var removedElements = 0
        
        comments = comments.filter({
            let filterResult = callback($0)
            
            // Remove the ID from the IDs set as well
            if !filterResult {
                ids.remove($0.commentModel.comment.id)
                removedElements += 1
            }
            return filterResult
        })
        
        return removedElements
    }
}
