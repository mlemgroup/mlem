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
    
    // passed in
    
    let post: Post
    
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
        // nested inside a ZStack so the center items are always perfectly centered
        ZStack {
            HStack {
                // upvote/downvote component
                HStack(spacing: 6) {
                    UpvoteButton(myVote: post.myVote)
                        .onTapGesture {
                            Task(priority: .userInitiated) {
                                await upvoteCallback()
                            }
                        }
                    
                    // TODO: something clever to keep time and comment count from shifting with upvote/downvote
                    Text(String(post.score))
                        .if (post.myVote == .upvoted) { viewProxy in
                            viewProxy.foregroundColor(.upvoteColor)
                        }
                        .if (post.myVote == .none) { viewProxy in
                            viewProxy.foregroundColor(.accentColor)
                        }
                        .if (post.myVote == .downvoted) { viewProxy in
                            viewProxy.foregroundColor(.downvoteColor)
                        }
                    DownvoteButton(myVote: post.myVote)
                        .onTapGesture {
                            Task(priority: .userInitiated) {
                                await downvoteCallback()
                            }
                        }
                }
                
                Spacer()
                
                // save/reply component
                HStack(spacing: 16) {
                    SaveButton(saved: post.saved)
                        .onTapGesture {
                            Task(priority: .userInitiated) {
                                await saveCallback()
                            }
                        }
                    ReplyButton()
                }
            }
            
            // post info component
            HStack(spacing: 8) {
                HStack(spacing: iconToTextSpacing) {
                    Image(systemName: "clock")
                    Text(getTimeIntervalFromNow(date: post.published))
                }
                HStack(spacing: iconToTextSpacing) {
                    Image(systemName: "bubble.left")
                    Text(String(post.numberOfComments))
                }
            }
            .foregroundColor(.secondary)
            .dynamicTypeSize(.small)
        }
        dirty = true
    }
}
