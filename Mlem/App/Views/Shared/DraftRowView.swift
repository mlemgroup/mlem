//
//  DraftRowView.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-11-27.
//

import SwiftUI
import MlemMiddleware

import os

struct DraftRowView: View {
    
    @Environment(AppState.self) var appState
    
    @State var draftMetadata: DraftMetadata
    @State var account: UserAccount?
    @State var targetComment: Comment?
    @State var targetPost: Post?
        
    var body: some View {
        content
            .task {
                account = AccountsTracker.main.userAccounts.first { $0.actorId == draftMetadata.author }
                do {
                    let resolvedTarget = try await appState.firstApi.resolve(url: draftMetadata.target.url)
                    Logger.dev.info("Resolved \(draftMetadata.target.url)")
                    if let comment = resolvedTarget as? Comment {
                        targetComment = comment
                    }
                    if let post = resolvedTarget as? Post {
                        targetPost = post
                    }
                } catch {
                    handleError(error)
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
        // if let account, let target {
            VStack {
                if let post = targetPost {
                    HStack(spacing: 0) {
                        Text("Post to ")
                        ExpectedView(post.community) { community in
                            FullyQualifiedLabelView(community, labelStyle: .small)
                        }
                    }
                } else if let comment = targetComment {
                    HStack(spacing: 0) {
                        Text("Reply to ")
                        ExpectedView(comment.creator) { creator in
                            FullyQualifiedLabelView(creator, labelStyle: .small)
                        }
                    }
                }
                
                if let account {
                    Text(account.name)
                }
            }
//        } else {
//            ProgressView()
//        }
    }
}
