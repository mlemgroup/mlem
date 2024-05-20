//
//  FeedPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct FeedPost: View {
    @AppStorage("post.size") var size: PostSize = .compact
    
    let post: AnyPost
    
    var body: some View {
        ContentLoader(model: post) { post in
            content(for: post)
        }
    }
    
    @ViewBuilder
    func content(for post: any Post1Providing) -> some View {
        switch size {
        case .compact:
            CompactPost(post: post)
        case .headline:
            HeadlinePost()
        case .large:
            LargePost()
        }
    }
}
