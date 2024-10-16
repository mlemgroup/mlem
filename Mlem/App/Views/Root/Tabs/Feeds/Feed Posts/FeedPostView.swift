//
//  FeedPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

/// View for rendering posts in feed
struct FeedPostView: View {
    @Setting(\.postSize) private var postSize
    
    @Environment(Palette.self) private var palette
    
    let post: any Post1Providing
    var overridePostSize: PostSize?
    
    var body: some View {
        content
            .contentShape(.interaction, .rect)
            .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
            .quickSwipes(post.swipeActions(behavior: postSize.swipeBehavior))
            .contextMenu { post.allMenuActions() }
            .paletteBorder(cornerRadius: postSize.swipeBehavior.cornerRadius)
    }
    
    @ViewBuilder
    var content: some View {
        switch overridePostSize ?? postSize {
        case .compact:
            CompactPostView(post: post)
        case .tile:
            TilePostView(post: post)
        case .headline:
            HeadlinePostView(post: post)
        case .large:
            LargePostView(post: post)
        }
    }
}
