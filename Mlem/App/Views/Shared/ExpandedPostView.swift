//
//  ExpandedPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-12.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct ExpandedPostView: View {
    @Environment(\.dismiss) var dismiss
    
    let post: AnyPost
    @State var comments: [Comment2] = []
    @State var loadingState: LoadingState = .idle
    
    var body: some View {
        ContentLoader(model: post) { post1, _ in
            content(for: post1)
                .task {
                    guard loadingState == .idle else { return }
                    loadingState = .loading
                    do {
                        comments = try await post1.getComments(page: 1, limit: 3)
                        loadingState = .done
                    } catch {
                        handleError(error)
                    }
                }
        }
    }
    
    func content(for post: any Post1Providing) -> some View {
        FancyScrollView {
            LazyVStack(alignment: .leading) {
                LargePostView(post: post, isExpanded: true)
                Divider()
                ForEach(comments) { comment in
                    VStack(alignment: .leading) {
                        Text(comment.content)
                        Divider()
                    }
                }
            }
        }
    }
}
