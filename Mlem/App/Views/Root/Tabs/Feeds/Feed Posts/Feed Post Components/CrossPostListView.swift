//
//  CrossPostListView.swift
//  Mlem
//
//  Created by Sjmarf on 25/09/2024.
//

import MlemMiddleware
import SwiftUI

struct CrossPostListView: View {
    @Environment(AppState.self) private var appState
    @Environment(Palette.self) private var palette
    
    @Environment(\.colorScheme) var colorScheme
    
    let post: any Post3Providing
    
    var shownCrossPosts: [Post2] {
        var output: [Post2] = []
        if let first = post.crossPosts.sorted(by: { $0.commentCount > $1.commentCount }).first {
            // Include the crosspost with highest comment count if it has a lot of comments
            if Double(first.commentCount) > Double(post.commentCount) * 0.8 {
                output.append(first)
            }
            // Include any crossposts from communities that you moderate
            output.append(contentsOf: post.crossPosts.dropFirst().filter { crossPost in
                (appState.firstSession as? UserSession)?.person?.moderates(community: crossPost.community) ?? false
            })
        }
        return output
    }
    
    var body: some View {
        if !post.crossPosts.isEmpty {
            VStack(spacing: 0) {
                NavigationLink(.crossPostList(.init(post))) {
                    HStack {
                        Image(systemName: Icons.crossPost)
                            .foregroundStyle(palette.tertiary)
                            .fontWeight(.semibold)
                        Text("\(post.crossPosts.count) Crossposts...")
                        Spacer()
                        Image(systemName: Icons.forward)
                            .imageScale(.small)
                            .fontWeight(.semibold)
                            .foregroundStyle(palette.tertiary)
                            .padding(.trailing, 4)
                    }
                    .foregroundStyle(palette.secondary)
                    .padding(.horizontal, Constants.main.standardSpacing)
                    .padding(.vertical, 8)
                    .contentShape(.rect)
                }
                .buttonStyle(EmptyButtonStyle())
                .background(colorScheme == .light || shownCrossPosts.isEmpty ? .clear : palette.tertiaryGroupedBackground)
                ForEach(shownCrossPosts) { crossPost in
                    Divider()
                    NavigationLink(.post(crossPost, communityContext: post.community)) {
                        FeedPostView(post: crossPost, overridePostSize: .compact)
                    }
                    .buttonStyle(EmptyButtonStyle())
                }
            }
            .background(palette.secondaryGroupedBackground)
            .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
        }
    }
}
