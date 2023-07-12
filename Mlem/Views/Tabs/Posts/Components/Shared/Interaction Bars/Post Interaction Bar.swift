//
//  File.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import SwiftUI

import Foundation

/**
 View grouping post interactions--upvote, downvote, save, reply, plus post info
 */
struct PostInteractionBar: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("voteComplexOnRight") var shouldShowVoteComplexOnRight: Bool = false
    @AppStorage("postVoteComplexStyle") var postVoteComplexStyle: VoteComplexStyle = .standard
    @AppStorage("shouldShowScoreInPostBar") var shouldShowScoreInPostBar: Bool = false
    @AppStorage("shouldShowTimeInPostBar") var shouldShowTimeInPostBar: Bool = true
    @AppStorage("shouldShowSavedInPostBar") var shouldShowSavedInPostBar: Bool = false
    @AppStorage("shouldShowRepliesInPostBar") var shouldShowRepliesInPostBar: Bool = true
    
    @EnvironmentObject var postTracker: PostTracker

    // state fakers--these let the upvote/downvote/score/save views update instantly even if the call to the server takes longer
    @State var dirtyVote: ScoringOperation
    @State var dirtyScore: Int
    @State var dirtySaved: Bool
    @State var dirty: Bool

    // computed properties--if dirty, show dirty value, otherwise show post value
    var displayedVote: ScoringOperation { dirty ? dirtyVote : postView.myVote ?? .resetVote }
    var displayedScore: Int { dirty ? dirtyScore : postView.counts.score }
    var displayedSaved: Bool { dirty ? dirtySaved : postView.saved }

    // parameters
    let postView: APIPostView
    let menuFunctions: [MenuFunction]
    let voteOnPost: (ScoringOperation) async -> Void
    let updatedSavePost: (_ save: Bool) async throws -> Void
    let deletePost: () async -> Void
    let replyToPost: (() -> Void)?
    
    init(
        postView: APIPostView,
        menuFunctions: [MenuFunction],
        voteOnPost: @escaping (ScoringOperation) async -> Void,
        updatedSavePost: @escaping (_ save: Bool) async throws -> Void,
        deletePost: @escaping () async -> Void,
        replyToPost: (() -> Void)?
    ) {
        self.postView = postView
        self.voteOnPost = voteOnPost
        self.menuFunctions = menuFunctions
        self.updatedSavePost = updatedSavePost
        self.deletePost = deletePost
        self.replyToPost = replyToPost
        _dirtyVote = State(initialValue: postView.myVote ?? .resetVote)
        _dirtyScore = State(initialValue: postView.counts.score)
        _dirtySaved = State(initialValue: postView.saved)
        _dirty = State(initialValue: false)
    }

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                if !shouldShowVoteComplexOnRight {
                    VoteComplex(style: postVoteComplexStyle,
                                vote: displayedVote,
                                score: displayedScore,
                                upvote: upvote,
                                downvote: downvote)
                        .padding(.trailing, 8)
                } else {
                    SaveButton(isSaved: displayedSaved, accessibilityContext: "post") {
                        Task(priority: .userInitiated) {
                            await savePost()
                        }
                    }
                    
                    ReplyButton(replyCount: postView.counts.comments, accessibilityContext: "post", reply: replyToPost)
                }
                
                Spacer()
                
                if shouldShowVoteComplexOnRight {
                    VoteComplex(style: postVoteComplexStyle,
                                vote: displayedVote,
                                score: displayedScore,
                                upvote: upvote,
                                downvote: downvote)
                        .padding(.trailing, 8)
                } else {
                    SaveButton(isSaved: displayedSaved, accessibilityContext: "post") {
                        Task(priority: .userInitiated) {
                            await savePost()
                        }
                    }
                    
                    ReplyButton(replyCount: postView.counts.comments, accessibilityContext: "post", reply: replyToPost)
                }
            }
            
            InfoStack(score: shouldShowScoreInPostBar ? postView.counts.score : nil,
                      myVote: shouldShowScoreInPostBar ? postView.myVote ?? .resetVote : nil,
                      published: shouldShowTimeInPostBar ? postView.published : nil,
                      commentCount: shouldShowRepliesInPostBar ? postView.counts.comments : nil,
                      saved: shouldShowSavedInPostBar ? postView.saved : nil)
        }
        .font(.callout)
    }
    
    // helper functions
    
    func canDeletePost() -> Bool {
        if postView.creator.id != appState.currentActiveAccount.id {
            return false
        }
        
        if postView.post.deleted {
            return false
        }
        
        return true
    }
    
    func upvote() async {
        // don't do anything if currently awaiting a vote response
        guard dirty else {
            // fake downvote
            switch displayedVote {
            case .upvote:
                dirtyVote = .resetVote
                dirtyScore = displayedScore - 1
            case .resetVote:
                dirtyVote = .upvote
                dirtyScore = displayedScore + 1
            case .downvote:
                dirtyVote = .upvote
                dirtyScore = displayedScore + 2
            }
            dirty = true

            // wait for vote
            await voteOnPost(.upvote)

            // unfake downvote
            dirty = false
            return
        }
    }

    func downvote() async {
        // don't do anything if currently awaiting a vote response
        guard dirty else {
            // fake upvote
            switch displayedVote {
            case .upvote:
                dirtyVote = .downvote
                dirtyScore = displayedScore - 2
            case .resetVote:
                dirtyVote = .downvote
                dirtyScore = displayedScore - 1
            case .downvote:
                dirtyVote = .resetVote
                dirtyScore = displayedScore + 1
            }
            dirty = true

            // wait for vote
            await voteOnPost(.downvote)

            // unfake upvote
            dirty = false
            return
        }
    }

    func deletePost() async {
        // don't do anything if currently awaiting a vote response
        guard dirty else {
            dirty = true
            
            // wait for deletion
            await deletePost()
            
            dirty = false
            return
        }
    }

    /**
     Sends a save request for the current post
     */
    func savePost() async {
        guard dirty else {
            do {
                // fake save
                dirtySaved.toggle()
                dirty = true
                try await self.updatedSavePost(dirtySaved)
            } catch {
                UIAccessibility.post(notification: .announcement, argument: "Failed to Save")
                appState.contextualError = .init(underlyingError: error)
            }
            dirty = false
            return
        }
    }
}
