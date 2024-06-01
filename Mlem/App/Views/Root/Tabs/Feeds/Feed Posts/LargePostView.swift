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
    @AppStorage("post.showCreator") var showCreator: Bool = false
    @AppStorage("user.showAvatar") var showUserAvatar: Bool = true
    @AppStorage("community.showAvatar") var showCommunityAvatar: Bool = true
    
    @Environment(\.communityContext) var communityContext: (any Community1Providing)?
    @Environment(Palette.self) var palette: Palette
    
    let post: any Post1Providing
    
    var body: some View {
        content
            .padding(AppConstants.standardSpacing)
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            HStack {
                FullyQualifiedLabelView(entity: post.community_, labelStyle: .large, showAvatar: showCommunityAvatar)
                
                Spacer()
                
                if post.nsfw {
                    Image(Icons.nsfwTag)
                        .foregroundStyle(palette.warning)
                }
                
                EllipsisMenu(actions: post.menuActions, size: 24)
            }
            
            post.taggedTitle(communityContext: communityContext)
                .font(.headline)
                .imageScale(.small)
            
            postDetail
            
            if showCreator {
                FullyQualifiedLinkView(entity: post.creator_, labelStyle: .large, showAvatar: showUserAvatar)
            }
        }
    }
    
    @ViewBuilder
    var postDetail: some View {
        switch post.postType {
        case let .text(text):
            Markdown(text, configuration: .default)
                .lineLimit(8)
                .foregroundStyle(palette.secondary)
        case .image:
            mockImage
        case let .link(url):
            if let url {
                mockWebsiteComplex(url: url)
            }
        case .titleOnly:
            EmptyView()
        }
    }
    
    var mockImage: some View {
        Image(systemName: "photo.artframe")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .foregroundStyle(palette.secondary)
    }
    
    func mockWebsiteComplex(url: URL) -> some View {
        Text(url.host ?? "no host found")
            .foregroundStyle(palette.secondary)
            .padding(AppConstants.standardSpacing)
            .frame(maxWidth: .infinity)
            .overlay {
                RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(palette.secondary)
            }
    }
}
