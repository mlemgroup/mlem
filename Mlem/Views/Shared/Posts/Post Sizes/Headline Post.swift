//
//  Compact Post.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-11.
//

import Foundation
import SwiftUI

struct HeadlinePost: View {
    // app storage
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("shouldShowUserServerInPost") var shouldShowUserServerInPost: Bool = true
    @AppStorage("shouldShowPostThumbnails") var shouldShowPostThumbnails: Bool = true
    @AppStorage("thumbnailsOnRight") var thumbnailsOnRight: Bool = false

    // constants
    let thumbnailSize: CGFloat = 60
    private let spacing: CGFloat = 10 // constant for readability, ease of modification

    // arguments
    @ObservedObject var post: PostModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.postAndCommentSpacing) {
            HStack(alignment: .top, spacing: spacing) {
                if shouldShowPostThumbnails, !thumbnailsOnRight {
                    ThumbnailImageView(post: post)
                }

                VStack(spacing: 2) {
                    HStack(alignment: .top, spacing: 4) {
                        if post.post.featuredLocal {
                            StickiedTag(tagType: .local)
                        } else if post.post.featuredCommunity {
                            StickiedTag(tagType: .community)
                        }
                        
                        Text(post.post.name)
                            .font(.headline)
                            .padding(.trailing)
                            .foregroundColor(post.read ? .secondary : .primary)
                        
                        Spacer()
                        if post.post.nsfw {
                            NSFWTag(compact: true)
                        }
                        if post.post.locked {
                            LockedTag(compact: false)
                        }
                        if post.post.removed {
                            RemovedTag(compact: false)
                        }
                    }
                }
                
                if shouldShowPostThumbnails, thumbnailsOnRight {
                    ThumbnailImageView(post: post)
                }
            }
        }
    }
}
