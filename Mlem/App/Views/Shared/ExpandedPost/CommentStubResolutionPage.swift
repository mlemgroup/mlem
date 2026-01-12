//
//  CommentStubResolutionPage.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-11.
//

import MlemMiddleware
import SwiftUI
import Theming

struct CommentStubResolutionPage: View {
    @Environment(NavigationLayer.self) var navigation
    
    let stub: any CommentStubProviding
    let comments: [Comment2]?
    let showViewPostButton: Bool
    let exposeRemovedContent: Bool
    
    @State var upgradeError: Error?
    
    var body: some View {
        if let upgradeError {
            ErrorView(.init(error: upgradeError))
        } else {
            ProgressView()
                .task {
                    do {
                        // TODO: UnifiedCommentModel remove this manual fetch and rework CommentPage accordingly
                        let upgraded = try await stub.upgrade()
                        let post: UnifiedPostModel
                        if let upgradedPost = upgraded.post_ {
                            post = upgradedPost
                        } else {
                            post = try await upgraded.api.getPost(id: upgraded.postId)
                        }
                        // TODO: NOW make this smoother
                        navigation.replace(.comment(
                            upgraded,
                            post: post,
                            comments: comments,
                            showViewPostButton: showViewPostButton,
                            exposeRemovedContent: exposeRemovedContent
                        ))
                    } catch {
                        upgradeError = error
                    }
                }
        }
    }
}
