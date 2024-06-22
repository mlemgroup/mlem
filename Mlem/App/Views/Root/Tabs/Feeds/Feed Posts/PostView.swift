//
//  PostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-21.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct PostView: View {
    @AppStorage("beta.tilePosts") var tilePosts: Bool = false
    
    let post: any Post1Providing
    
    var body: some View {
        content
            .quickSwipes(post.swipeActions(behavior: tilePosts ? .tile : .standard))
    }
    
    @ViewBuilder
    var content: some View {
        if tilePosts {
            TilePostView(post: post)
        } else {
            FeedPostView(post: post)
        }
    }
}
