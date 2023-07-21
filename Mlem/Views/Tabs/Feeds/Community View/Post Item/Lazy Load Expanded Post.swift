//
//  Lazy Load Expanded Post.swift
//  Mlem
//
//  Created by Jake Shirey on 23.06.2023.
//

import SwiftUI

/*
 A simple wrapper around ExpandedPost which loads the
 APIPostView on demand for when we don't already have one
 */
struct LazyLoadExpandedPost: View {
    
    @EnvironmentObject var appState: AppState
    
    @State var post: APIPost
    
    @State private var loadedPostView: APIPostView?

    @StateObject private var postTracker =  PostTracker()

    var body: some View {
        Group {
            if let loadedPost = loadedPostView {
                ExpandedPost(post: loadedPost)
                    .environmentObject(postTracker)
            } else {
                progressView
            }
        }
    }
    
    private var progressView: some View {
        ProgressView {
            Text("Loading post details…")
        }
        .task(priority: .background) {
            let request = GetPostRequest(account: appState.currentActiveAccount, id: post.id, commentId: nil)
            do {
                let response = try await APIClient().perform(request: request)
                postTracker.add([response.postView])
                loadedPostView = response.postView
            } catch {
                print("Get post error: \(error)")
                // TODO: Some sort of common alert banner?
                appState.contextualError = .init(underlyingError: error)
            }
        }
    }
}
