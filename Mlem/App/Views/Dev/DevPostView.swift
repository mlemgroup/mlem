//
//  DevPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-12-18.
//

import SwiftUI
import MlemMiddleware
import ComponentViews

struct ExpectedText: View {
    let text: String?
    
    var body: some View {
        if let text {
            Text(text)
        } else {
            MockTextView()
        }
    }
}

struct DevPostView: View {
    @Environment(AppState.self) var appState
    
    @State var postModel: UnifiedPostModel
    
    init(post: any Post1Providing) {
        self.postModel = .init(api: post.api, url: post.url())
    }
    
    var body: some View {
        ExpectedText(text: postModel.title)
    }
}
