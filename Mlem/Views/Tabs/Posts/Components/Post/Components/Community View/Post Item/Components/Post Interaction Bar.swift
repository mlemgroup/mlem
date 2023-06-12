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
    // MARK constants and variables
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var postTracker: PostTracker
    
    // constants
    let iconToTextSpacing: CGFloat = 2
    let iconPadding: CGFloat = 4
    let iconCorner: CGFloat = 2
    let scoreItemWidth: CGFloat = 12
    
    // state fakers--these let the upvote/downvote/score/save views update instantly even if the call to the server takes longer
//    @State var displayedVote: ScoringOperation
//    @State var displayedScore: Int
//    @State var displayedSaved: Bool
//    var dirty: Bool
    
    
    // passed in
    
    let post: APIPostView
    
    let account: SavedAccount
    
    let compact: Bool
    
//    init(post: APIPostView, account: SavedAccount, compact: Bool) {
//        self.post = post
//        self.account = account
//        self.compact = compact
//        self.dirty = false
//        _displayedVote = State(initialValue: post.myVote ?? .resetVote)
//        _displayedScore = State(initialValue: post.counts.score)
//        _displayedSaved = State(initialValue: false)
    // }
    
    var body: some View {
        VStack(spacing: 0) {
            if (!compact) {
                Divider()
            }
            
            // nested inside a ZStack so the info block is always perfectly centered
            ZStack {
                HStack {
                    voteBlock
                    Spacer()
                    saveReplyBlock
                }
                infoBlock
            }
            .padding(.horizontal)
            .padding(.vertical, compact ? 2 : 4)
        }
        .dynamicTypeSize(compact ? .small : .medium)
    }
    
    // subviews
    
    /**
     Displays the upvote/downvote button and the score
     */
    var voteBlock: some View {
        HStack(spacing: 6) {
            UpvoteButton(myVote: post.myVote ?? .resetVote)
                .onTapGesture {
                    Task(priority: .userInitiated) {
                        // update the fakers. if the upvote fails, reset the fakers
                        // fakeUpvote()
                        await voteOnPost(inputOp: .upvote)
                    }
                }
            Text(String(post.counts.score))
                .if (post.myVote == .upvote) { viewProxy in
                    viewProxy.foregroundColor(.upvoteColor)
                }
                .if (post.myVote == .resetVote) { viewProxy in
                    viewProxy.foregroundColor(.primary)
                }
                .if (post.myVote == .downvote) { viewProxy in
                    viewProxy.foregroundColor(.downvoteColor)
                }
            DownvoteButton(myVote: post.myVote ?? .resetVote)
                .onTapGesture {
                    Task(priority: .userInitiated) {
                        // update the fakers. if the downvote fails, reset the fakers
                        // fakeDownvote()
                        await voteOnPost(inputOp: .downvote)
                    }
                }
        }
    }
    
    /**
     Displays the save and reply buttons
     */
    var saveReplyBlock: some View {
        HStack(spacing: 16) {
            // TODO: change all this once saving is implemented
            SaveButton(saved: false)
                .onTapGesture {
                    Task(priority: .userInitiated) {
                        await savePost()
                    }
                }
            ReplyButton()
        }
    }
    
    var infoBlock: some View {
        // post info component
        HStack(spacing: 8) {
            HStack(spacing: iconToTextSpacing) {
                Image(systemName: "clock")
                Text(getTimeIntervalFromNow(date: post.post.published))
            }
            HStack(spacing: iconToTextSpacing) {
                Image(systemName: "bubble.left")
                Text(String(post.counts.comments))
            }
        }
        .foregroundColor(.secondary)
    }
    
    // helper functions
    
    /**
     Sends a vote request for the current post
     */
    func voteOnPost(inputOp: ScoringOperation) async -> Bool {
        do {
            let operation = post.myVote == inputOp ? ScoringOperation.resetVote : inputOp
            try await ratePost(post: post.post, operation: operation, account: account, postTracker: postTracker, appState: appState)
        } catch {
            print("vote failed")
            return false
        }
        print("vote succeeded")
        return true
    }
    
    /**
     Sends a save request for the current post
     */
    func savePost() async -> Bool {
        do {
#warning("TODO: Make this actually save a post")
        } catch {
            return false
        }
        return true
    }
    
    /**
     Fakes an upvote, immediately updating the displayed values
     */
//    func fakeUpvote() {
//        switch (post.myVote) {
//        case .upvote:
//            displayedVote = .resetVote
//            displayedScore -= 1
//        case .resetVote:
//            displayedVote = .upvote
//            displayedScore += 1
//        case .downvote:
//            displayedVote = .upvote
//            displayedScore += 2
//        }
//    }
    
    /**
     Fakes a downvote, immediately updating the displayed values
     */
//    func fakeDownvote() {
//        switch (displayedVote) {
//        case .upvote:
//            displayedVote = .downvote
//            displayedScore -= 2
//        case .resetVote:
//            displayedVote = .downvote
//            displayedScore -= 1
//        case .downvote:
//            displayedVote = .resetVote
//            displayedScore += 1
//        }
//    }
    
    /**
     Reverts the displayed vote and score to the value from post
     */
//    func displayTrueVoteAndScore() {
//        displayedVote = post.myVote ?? .resetVote
//        displayedScore = post.counts.score
//    }
}
