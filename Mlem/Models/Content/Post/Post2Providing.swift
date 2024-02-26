//
//  Post2Providing.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

protocol Post2Providing: InteractableContent, Post1Providing {
    var post2: Post2 { get }
    
    var creator: Person1 { get }
    var community: Community1 { get }

    var unreadCommentCount: Int { get }
    var isRead: Bool { get set }
    
    func update(with post: ApiPostView)
}

extension Post2Providing {
    var post1: Post1 { post2.post1 }
    
    var creator: Person1 { post2.creator }
    var community: Community1 { post2.community }
    var commentCount: Int { post2.commentCount }
    var upvoteCount: Int { post2.upvoteCount }
    var downvoteCount: Int { post2.downvoteCount }
    var unreadCommentCount: Int { post2.unreadCommentCount }
    var isSaved: Bool { post2.isSaved }
    var isRead: Bool { get { post2.isRead } set { post2.isRead = newValue } }
    var myVote: ScoringOperation { post2.myVote }
    
    var creator_: Person1? { post2.creator }
    var community_: Community1? { post2.community }
    var commentCount_: Int? { post2.commentCount }
    var upvoteCount_: Int? { post2.upvoteCount }
    var downvoteCount_: Int? { post2.downvoteCount }
    var unreadCommentCount_: Int? { post2.unreadCommentCount }
    var isSaved_: Bool? { post2.isSaved }
    var isRead_: Bool? { post2.isRead }
    var myVote_: ScoringOperation? { post2.myVote }
    
    var score: Int { upvoteCount - downvoteCount }
    
    func vote(_ newVote: ScoringOperation) {
        if let oldTask = post2.tasks.vote, !oldTask.isCancelled { oldTask.cancel() }
        post2.tasks.vote = Task(priority: .userInitiated) { await voteTask(newVote) }
    }
    
    func voteTask(_ newVote: ScoringOperation) async {
        if newVote == myVote { return }
        
        let oldVote = myVote
        let oldUpvoteCount = upvoteCount
        let oldDownvoteCount = downvoteCount
        let oldReadStatus = isRead
        
        DispatchQueue.main.async {
            self.upvoteCount += newVote.upvoteValue - oldVote.upvoteValue
            self.downvoteCount += newVote.downvoteValue - oldVote.downvoteValue
            self.myVote = newVote
            self.isRead = true
        }
        
        do {
            let response = try await source.api.voteOnPost(id: id, score: newVote)
            if !Task.isCancelled {
                DispatchQueue.main.async {
                    self.post2.update(with: response.postView, excludeActions: true)
                    self.post2.tasks.vote = nil
                }
            } else {
                print("\(newVote) task cancelled (Request)")
            }
        } catch ApiClientError.cancelled {
            print("\(newVote) task cancelled (APIClient)")
            post2.tasks.vote = nil
        } catch {
            print("\(newVote) task error: \(error)")
            DispatchQueue.main.async {
                self.myVote = oldVote
                self.upvoteCount = oldUpvoteCount
                self.downvoteCount = oldDownvoteCount
                self.isRead = oldReadStatus
            }
            post2.tasks.vote = nil
        }
    }
    
    func toggleSave() {
        let wasSaved = isSaved
        if let oldTask = post2.tasks.save, !oldTask.isCancelled { oldTask.cancel() }
        post2.tasks.save = Task(priority: .userInitiated) { await toggleSaveTask() }
        if myVote != .upvote, !wasSaved, UserDefaults.standard.bool(forKey: "upvoteOnSave") {
            vote(.upvote)
        }
    }
    
    private func toggleSaveTask() async {
        let oldSavedStatus = isSaved
        let oldReadStatus = isRead
        
        let newSavedStatus = !isSaved
        
        DispatchQueue.main.async {
            self.isSaved = newSavedStatus
            self.isRead = true
        }
        do {
            let response = try await source.api.savePost(id: id, shouldSave: newSavedStatus)
            if !Task.isCancelled {
                DispatchQueue.main.async {
                    self.post2.update(with: response.postView, excludeActions: true)
                    self.post2.tasks.save = nil
                }
            } else {
                print("Save task cancelled (Request)")
            }
        } catch ApiClientError.cancelled {
            print("Save task cancelled (APIClient)")
            post2.tasks.save = nil
        } catch {
            print("Save task error: \(error)")
            DispatchQueue.main.async {
                self.isSaved = oldSavedStatus
                self.isRead = oldReadStatus
            }
            post2.tasks.save = nil
        }
    }
    
    var menuFunctions: [MenuFunction] {
        var functions = [MenuFunction]()
        functions.append(
            .standardMenuFunction(
                text: myVote == .upvote ? "Undo Upvote" : "Upvote",
                imageName: myVote == .upvote ? Icons.upvoteSquareFill : Icons.upvoteSquare,
                callback: self.toggleUpvote
            )
        )
        functions.append(
            .standardMenuFunction(
                text: myVote == .downvote ? "Undo Downvote" : "Downvote",
                imageName: myVote == .downvote ? Icons.downvoteSquareFill : Icons.downvoteSquare,
                callback: self.toggleDownvote
            )
        )
        functions.append(
            .standardMenuFunction(
                text: isSaved ? "Unsave" : "Save",
                imageName: isSaved ? Icons.saveFill : Icons.save,
                callback: self.toggleSave
            )
        )
        functions.append(.shareMenuFunction(url: actorId))
        return functions
    }
}
