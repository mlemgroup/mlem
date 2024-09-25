//
//  CrossPostListView.swift
//  Mlem
//
//  Created by Sjmarf on 25/09/2024.
//

import MlemMiddleware
import SwiftUI

struct CrossPostListPage: View {
    @Environment(Palette.self) var palette
    
    let post: AnyPost
    
    var body: some View {
        ContentLoader(model: post) { proxy in
            if let post = proxy.entity as? any Post3Providing {
                FancyScrollView {
                    LazyVStack(spacing: Constants.main.halfSpacing) {
                        ForEach(post.crossPosts) { crossPost in
                            NavigationLink(.post(crossPost, communityContext: post.community)) {
                                FeedPostView(post: crossPost, overridePostSize: .compact)
                            }
                            .buttonStyle(EmptyButtonStyle())
                            .padding(.horizontal, Constants.main.standardSpacing)
                        }
                    }
                }
                .background(palette.groupedBackground)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(palette.groupedBackground)
            }
        }
        .navigationTitle("Crossposts")
    }
}
