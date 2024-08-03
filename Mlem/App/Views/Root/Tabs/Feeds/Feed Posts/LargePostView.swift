//
//  LargePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct LargePostView: View {
    @AppStorage("post.showCreator") private var showCreator: Bool = false
    @AppStorage("user.showAvatar") private var showUserAvatar: Bool = true
    @AppStorage("community.showAvatar") private var showCommunityAvatar: Bool = true
    
    @Environment(\.communityContext) private var communityContext: (any Community1Providing)?
    @Environment(Palette.self) private var palette: Palette
    
    let post: any Post1Providing
    var isExpanded: Bool = false
    
    var body: some View {
        content
            .padding(AppConstants.standardSpacing)
            .background(palette.background)
            .environment(\.postContext, post)
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            HStack {
                FullyQualifiedLabelView(entity: post.community_, labelStyle: .medium, showAvatar: showCommunityAvatar)
                
                Spacer()
                
                if post.nsfw {
                    Image(Icons.nsfwTag)
                        .foregroundStyle(palette.warning)
                }
                
                if !isExpanded {
                    EllipsisMenu(actions: post.menuActions(), size: 24)
                }
            }
            
            post.taggedTitle(communityContext: communityContext)
                .foregroundStyle((post.read_ ?? false) ? palette.secondary : palette.primary)
                .font(.headline)
                .imageScale(.small)
            
            postDetail
            
            if showCreator || isExpanded {
                FullyQualifiedLinkView(entity: post.creator_, labelStyle: .medium, showAvatar: showUserAvatar)
            }
            
            InteractionBarView(
                post: post,
                configuration: .init(
                    leading: [.counter(.score)],
                    trailing: [.action(.save), .action(.reply)],
                    readouts: [.created, .score, .comment]
                )
            )
            .padding(.vertical, 2)
        }
    }
    
    @ViewBuilder
    var postDetail: some View {
        switch post.type {
        case let .image(url):
            LargeImageView(url: url, nsfw: post.nsfw)
                // Set maximum image height to 1.2 * width
                .aspectRatio(CGSize(width: 1, height: 1.2), contentMode: .fill)
                .frame(maxWidth: .infinity)
        case let .link(link):
            WebsitePreviewView(link: link, nsfw: post.nsfw)
        default:
            EmptyView()
        }
        if let content = post.content {
            if isExpanded {
                Markdown(content, configuration: post.nsfw ? .defaultBlurred : .default)
            } else {
                // Cut down on compute time for very long text posts by only rendering the first 4 blocks
                MarkdownText(Array([BlockNode](content).prefix(4)), configuration: .dimmed)
                    .lineLimit(post.linkUrl == nil ? 8 : 4)
            }
        }
    }
    
    var mockImage: some View {
        Image(systemName: "photo.artframe")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .foregroundStyle(palette.secondary)
    }
}
