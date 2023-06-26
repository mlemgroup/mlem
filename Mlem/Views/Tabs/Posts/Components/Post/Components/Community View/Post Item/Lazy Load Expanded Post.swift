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
struct LazyLoadExpandedPost: View
{
    @State var account: SavedAccount
    @State var post: APIPost
    
    @State private var loadedPostView: APIPostView? = nil
    
    var body: some View {
        ZStack {
            if let loadedPost = loadedPostView {
                ExpandedPost(account: account, post: loadedPost, feedType: .constant(.subscribed))
            }
            else {
                progressView
            }
        }
    }
    
    private var progressView: some View {
        ProgressView {
            Text("Loading post details…")
        }
        .task(priority: .background) {
            let request = GetPostRequest(account: account, id: post.id, commentId: nil)
            do {
                let response = try await APIClient().perform(request: request)
                loadedPostView = response.postView
            } catch {
                print("Get post error: \(error)")
                // TODO: Some sort of common alert banner?
            }
        }
    }
}
