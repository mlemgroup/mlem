//
//  DevPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-12-18.
//

import SwiftUI
import MlemMiddleware
import ComponentViews

struct DevPostView: View {
    @Environment(AppState.self) var appState
    
    @State var postModel: UnifiedPostModel
    
    init(post: any Post1Providing) {
        self.postModel = .init(api: post.api, url: post.url())
    }
    
    var animationHashValue: Int {
        var hasher = Hasher()
        hasher.combine(postModel.title != nil ? 1 : 0)
        return hasher.finalize()
    }
    
    var body: some View {
        ExpectedText(postModel.title)
    }
}
