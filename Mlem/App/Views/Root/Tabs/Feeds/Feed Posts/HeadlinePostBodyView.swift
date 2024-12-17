//
//  HeadlinePostBodyView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-17.
//

import MlemMiddleware
import SwiftUI

struct HeadlinePostBodyView: View {
    @Environment(Palette.self) var palette
    @Environment(\.communityContext) var communityContext: (any Community1Providing)?
    
    @Setting(\.thumbnailLocation) var thumbnailLocation
    @Setting(\.blurNsfw) var blurNsfw

    let post: any Post
    
    var blurred: Bool {
        switch blurNsfw {
        case .always: post.nsfw
        case .outsideCommunity: post.nsfw && !(communityContext?.nsfw ?? false)
        case .never: false
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: Constants.main.standardSpacing) {
            if thumbnailLocation == .left {
                ThumbnailImageView(
                    post: post,
                    blurred: blurred,
                    size: .standard,
                    frame: .init(width: Constants.main.thumbnailSize, height: Constants.main.thumbnailSize)
                )
            }

            VStack(alignment: .leading, spacing: Constants.main.halfSpacing) {
                post.taggedTitle(communityContext: communityContext)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle((post.read_ ?? false) ? palette.secondary : palette.primary)
                    .font(.headline)
                    .imageScale(.small)
                
                if let host = post.linkHost {
                    PostLinkHostView(host: host)
                        .font(.subheadline)
                }
            }
            
            if thumbnailLocation == .right {
                Spacer()
                ThumbnailImageView(
                    post: post,
                    blurred: blurred,
                    size: .standard,
                    frame: .init(width: Constants.main.thumbnailSize, height: Constants.main.thumbnailSize)
                )
            }
        }
    }
}
