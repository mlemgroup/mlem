//
//  CommentContextHeaderView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-29.
//

import MlemMiddleware
import SwiftUI

struct CommentContextHeaderView: View {
    @Environment(NavigationLayer.self) var navigation
    
    @Setting(\.blurNsfw) var blurNsfw
    
    let post: any Post
    let community: (any Community)?
    
    var imageUrl: URL? {
        switch post.type {
        case let .media(url), let .embedded(url, _): url
        case let .link(link): link.thumbnail
        default: nil
        }
    }
    
    var body: some View {
        HStack {
            MediaView(
                url: imageUrl,
                size: .init(width: 40, height: 40),
                controlState: .constant(.init(
                    blurred: post.nsfw && blurNsfw != .never,
                    animating: false,
                    overlays: []
                )),
                aspectRatioBounds: .absoluteSquare,
                contentMode: .fill,
                cornerRadius: 10,
                fallback: post.imageFallback
            )
            .frame(width: 40, height: 40)
            VStack(alignment: .leading) {
                Text(post.title)
                    .bold()
                Text(community?.fullName ?? "")
            }
            .lineLimit(1)
            .font(.footnote)
            .foregroundStyle(.themedSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onTapGesture {
            navigation.push(.post(post))
        }
    }
}
