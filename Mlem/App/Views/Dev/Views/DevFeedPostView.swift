//
//  DevFeedPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-05.
//

import SwiftUI
import MlemMiddleware

struct DevFeedPostView: View {
    @State var post: UnifiedPostModel
    
    init(post: UnifiedPostModel) {
        self.post = post
    }
    
    var body: some View {
        Text(post.title)
    }
}
