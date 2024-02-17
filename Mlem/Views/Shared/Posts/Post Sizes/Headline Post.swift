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
    let post: any Post

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.postAndCommentSpacing) {
            HStack(alignment: .top, spacing: spacing) {
                if shouldShowPostThumbnails, !thumbnailsOnRight {
                    ThumbnailImageView(post: post)
                }

                VStack(spacing: 2) {
                    HStack(alignment: .top, spacing: 4) {
                        if post.pinnedInstance {
                            StickiedTag(tagType: .local)
                        } else if post.pinnedCommunity {
                            StickiedTag(tagType: .community)
                        }
                        
                        Text(post.title)
                            .font(.headline)
                            .padding(.trailing)
                            .foregroundColor((post.isRead ?? false) ? .secondary : .primary)
                        
                        Spacer()
                        if post.nsfw {
                            NSFWTag(compact: true)
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
