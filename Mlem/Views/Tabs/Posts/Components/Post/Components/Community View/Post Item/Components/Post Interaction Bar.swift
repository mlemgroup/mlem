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
    
    // constants
    let iconToTextSpacing: CGFloat = 2
    let iconPadding: CGFloat = 4
    let iconCorner: CGFloat = 2
    let scoreItemWidth: CGFloat = 12
    
    let post: Post
    
    var upvoteCallback: () async -> Bool
    
    var downvoteCallback: () async -> Bool
    
    var saveCallback: () async -> Bool
    
    // MARK Body
    
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
        .padding(.horizontal)
    }
}

