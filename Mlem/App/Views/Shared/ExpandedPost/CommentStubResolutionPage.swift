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
    
    let stub: CommentStub
    let comments: [Comment]?
    let showViewPostButton: Bool
    let exposeRemovedContent: Bool
    
    @State var upgradeError: Error?
    
    var body: some View {
        content
            .themedGroupedBackground()
    }
    
    @ViewBuilder
    var content: some View {
        if let upgradeError {
            ErrorView(.init(
                error: upgradeError,
                refresh: fetchComment
            ))
        } else {
            ProgressView()
                .task {
                    await fetchComment()
                }
        }
    }
    
    @discardableResult
    func fetchComment() async -> Bool {
        do {
            // TODO: NOW make this smoother
            try await navigation.replace(.comment(
                stub.asComment(),
                comments: comments,
                showViewPostButton: showViewPostButton,
                exposeRemovedContent: exposeRemovedContent
            ))
            return true
        } catch {
            upgradeError = error
            return false
        }
    }
}
