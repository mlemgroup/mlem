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
    // @EnvironmentObject var postTracker: PostTracker
    @StateObject var postTracker: PostTracker
    
    // constants
    let iconToTextSpacing: CGFloat = 2
    let iconPadding: CGFloat = 4
    let iconCorner: CGFloat = 2
    let scoreItemWidth: CGFloat = 12
    
    // passed in
    
    @State var post: APIPostView
    
    let account: SavedAccount
    
    let compact: Bool
    
    func voteOnPost(inputOp: ScoringOperation) async -> Bool {
        do {
            let operation = post.myVote == inputOp ? ScoringOperation.resetVote : inputOp
            print("attempting to perform \(operation) on post")
            try await ratePost(post: post.post, operation: operation, account: account, postTracker: postTracker, appState: appState)
        } catch {
            return false
        }
        return true
    }
    
    func savePost() async -> Bool {
        do {
#warning("TODO: Make this actually save a post")
        } catch {
            return false
        }
        return true
    }
    
    
    
    // MARK Body
    
    var body: some View {
        VStack(spacing: 0) {
            if (!compact) {
                Divider()
            }
            
            // nested inside a ZStack so the center items are always perfectly centered
            ZStack {
                HStack {
                    // upvote/downvote component
                    HStack(spacing: 6) {
                        UpvoteButton(myVote: post.myVote ?? .resetVote)
                            .onTapGesture {
                                Task(priority: .userInitiated) {
                                    // await upvotePost()
                                    await voteOnPost(inputOp: .upvote)
                                }
                            }
                        Text(String(post.counts.score))
                            .if (post.myVote == .upvote) { viewProxy in
                                viewProxy.foregroundColor(.upvoteColor)
                            }
                            .if (post.myVote == .none) { viewProxy in
                                viewProxy.foregroundColor(.primary)
                            }
                            .if (post.myVote == .downvote) { viewProxy in
                                viewProxy.foregroundColor(.downvoteColor)
                            }
                        DownvoteButton(myVote: post.myVote ?? .resetVote)
                            .onTapGesture {
                                Task(priority: .userInitiated) {
                                    await voteOnPost(inputOp: .downvote)
                                }
                            }
                    }
                    
                    Spacer()
                    
                    // save/reply component
                    HStack(spacing: 16) {
                        // TODO: change all this once saving is implemented
                        SaveButton(saved: false)
                        // SaveButton(saved: post.saved)
                            .onTapGesture {
                                Task(priority: .userInitiated) {
                                    await savePost()
                                }
                            }
                        ReplyButton()
                    }
                }
                
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
            .padding(.horizontal)
            .padding(.vertical, compact ? 2 : 4)
        }
        .dynamicTypeSize(compact ? .small : .medium)
    }
}
