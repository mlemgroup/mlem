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
//    @EnvironmentObject var appState: AppState
//    @EnvironmentObject var postTracker: PostTracker
    
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
    var displayedVote: ScoringOperation { dirty ? dirtyVote : post.myVote ?? .resetVote }
    var displayedScore: Int { dirty ? dirtyScore : post.counts.score }
    
    // arguments
    let post: APIPostView
    let account: SavedAccount
    let compact: Bool
    
    // callback to upvote the post. I don't like that this is passed in, but I can't make the post update properly if I define it here--the delay between the value being updated in the postTracker and that value being propagated down here makes it flicker in a way that's not very nice
    var voteOnPost: (ScoringOperation) async -> Bool
    
    init(post: APIPostView, account: SavedAccount, compact: Bool, voteOnPost: @escaping (ScoringOperation) async -> Bool) {
        self.post = post
        self.account = account
        self.compact = compact
        self.voteOnPost = voteOnPost
        _dirty = State(initialValue: false)
        _dirtyVote = State(initialValue: post.myVote ?? .resetVote)
        _dirtyScore = State(initialValue: post.counts.score)
        _dirtySaved = State(initialValue: false)
     }
    
    var body: some View {
        VStack(spacing: 0) {
            if !compact { Divider() }
            
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
            UpvoteButton(myVote: displayedVote)
                .onTapGesture {
                    Task(priority: .userInitiated) {
                        fakeUpvote()
                        await voteOnPost(.upvote)
                        dirty = false
                    }
                }
            Text(String(displayedScore))
                .if (displayedVote == .upvote) { viewProxy in
                    viewProxy.foregroundColor(.upvoteColor)
                }
                .if (displayedVote == .resetVote) { viewProxy in
                    viewProxy.foregroundColor(.primary)
                }
                .if (displayedVote == .downvote) { viewProxy in
                    viewProxy.foregroundColor(.downvoteColor)
                }
            DownvoteButton(myVote: displayedVote)
                .onTapGesture {
                    Task(priority: .userInitiated) {
                        fakeDownvote()
                        await voteOnPost(.downvote)
                        dirty = false
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
    func fakeUpvote() {
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
    }
    
    /**
     Fakes a downvote, immediately updating the displayed values
     */
    func fakeDownvote() {
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
    }
}
