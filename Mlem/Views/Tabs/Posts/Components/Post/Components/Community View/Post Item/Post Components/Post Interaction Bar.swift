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
    let height: CGFloat = 24

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
    let menuFunctions: [MenuFunction]
    let voteOnPost: (ScoringOperation) async -> Void
    let updatedSavePost: (_ save: Bool) async throws -> Void
    let deletePost: () async -> Void
    let replyToPost: (() -> Void)?
    
    // computed
    var publishedAgo: String { getTimeIntervalFromNow(date: postView.post.published )}
    
    init(
        postView: APIPostView,
        account: SavedAccount,
        menuFunctions: [MenuFunction],
        voteOnPost: @escaping (ScoringOperation) async -> Void,
        updatedSavePost: @escaping (_ save: Bool) async throws -> Void,
        deletePost: @escaping () async -> Void,
        replyToPost: (() -> Void)?
    ) {
        self.postView = postView
        self.account = account
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
            HStack(spacing: 12) {
                VoteComplex(vote: displayedVote, score: displayedScore, height: height, upvote: upvote, downvote: downvote)
                    .padding(.trailing, 8)
                
                EllipsisMenu(
                    size: height,
                    menuFunctions: menuFunctions
                )
                
                Spacer()
                
                SaveButton(isSaved: displayedSaved, size: height, accessibilityContext: "post") {
                    Task(priority: .userInitiated) {
                        await savePost()
                    }
                }
                
                ReplyButton(replyCount: postView.counts.comments, accessibilityContext: "post", reply: replyToPost)
            }
            
            HStack(spacing: iconToTextSpacing) {
                Image(systemName: "clock")
                Text(publishedAgo)
            }
            .accessibilityAddTraits(.isStaticText)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Published \(publishedAgo) ago")
            .foregroundColor(.secondary)
        }
        .font(.callout)
    }
    
    // helper functions
    
    func canDeletePost() -> Bool {
        if postView.creator.id != account.id {
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
                print("failed to save!")
            }
            dirty = false
            return
        }
    }
}
