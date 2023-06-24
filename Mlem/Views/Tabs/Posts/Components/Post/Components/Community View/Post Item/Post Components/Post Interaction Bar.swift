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
    @EnvironmentObject var postTracker: PostTracker
    
    // constants
    let iconToTextSpacing: CGFloat = 2
    let iconPadding: CGFloat = 4
    let iconCorner: CGFloat = 2
    let scoreItemWidth: CGFloat = 12
    
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
    let account: SavedAccount
    let compact: Bool
    let voteOnPost: (ScoringOperation) async -> Void
    let updatedSavePost: (_ save: Bool) async throws -> Void
    
    // computed
    var publishedAgo: String { getTimeIntervalFromNow(date: postView.post.published )}
    var height: CGFloat { compact ? 20 : 24 }
    
    init(postView: APIPostView, account: SavedAccount, compact: Bool, voteOnPost: @escaping (ScoringOperation) async -> Void, updatedSavePost: @escaping (_ save: Bool) async throws -> Void) {
        self.postView = postView
        self.account = account
        self.compact = compact
        self.voteOnPost = voteOnPost
        self.updatedSavePost = updatedSavePost
        _dirtyVote = State(initialValue: postView.myVote ?? .resetVote)
        _dirtyScore = State(initialValue: postView.counts.score)
        _dirtySaved = State(initialValue: postView.saved)
        _dirty = State(initialValue: false)
    }
    
    var body: some View {
        HStack(spacing: compact ? 18 : 12) {
            VoteComplex(vote: displayedVote, score: displayedScore, height: height, upvote: upvote, downvote: downvote)
                .padding(.trailing, 8)
            
            SaveButton(isSaved: displayedSaved, size: height, accessibilityContext: "post") {
                Task(priority: .userInitiated) {
                    await savePost()
                }
            }
            
            if let postURL = URL(string: postView.post.apId) {
                ShareButton(size: height, accessibilityContext: "post") {
                    showShareSheet(URLtoShare: postURL)
                }
            }
            
            EllipsisMenu(size: height, shareUrl: postView.post.apId)
            
            Spacer()
            infoBlock
        }
        .font(compact ? .footnote : .callout)
    }
    
    // subviews
    
    var infoBlock: some View {
        // post info component
        HStack(spacing: 8) {
            HStack(spacing: iconToTextSpacing) {
                Image(systemName: "clock")
                Text(publishedAgo)
            }
            HStack(spacing: iconToTextSpacing) {
                Image(systemName: "bubble.left")
                Text(String(postView.counts.comments))
            }
        }
        .foregroundColor(.secondary)
    }
    
    // helper functions
    
    func upvote() async -> Void {
        // don't do anything if currently awaiting a vote response
        guard dirty else {
            // fake downvote
            switch (displayedVote) {
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
    
    func downvote() async -> Void {
        // don't do anything if currently awaiting a vote response
        guard dirty else {
            // fake upvote
            switch (displayedVote) {
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
    
    /**
     Sends a save request for the current post
     */
    func savePost() async -> Void {
        guard dirty else {
            do {
                // fake save
                dirtySaved.toggle()
                dirty = true
                try await self.updatedSavePost(dirtySaved)
            } catch {
                print("failed to save!")
            }
            dirty = false
            return
        }
    }
}
