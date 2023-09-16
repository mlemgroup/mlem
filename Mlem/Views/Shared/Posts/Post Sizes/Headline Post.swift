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
    let postView: APIPostView

    // computed
    var usernameColor: Color {
        if postView.creator.admin ?? false {
            return .red
        }
        if postView.creator.botAccount {
            return .indigo
        }

        return .secondary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.postAndCommentSpacing) {
            HStack(alignment: .top, spacing: spacing) {
                if shouldShowPostThumbnails && !thumbnailsOnRight {
                    ThumbnailImageView(postView: postView)
                }

                VStack(spacing: 2) {
                    HStack(alignment: .top, spacing: 4) {
                        if postView.post.featuredLocal {
                            StickiedTag(tagType: .local)
                        } else if postView.post.featuredCommunity {
                            StickiedTag(tagType: .community)
                        }
                        
                        Text(postView.post.name)
                            .font(.headline)
                            .padding(.trailing)
                            .foregroundColor(postView.read ? .secondary : .primary)
                        
                        Spacer()
                        if postView.post.nsfw {
                            NSFWTag(compact: true)
                            
                        }
                    }
                }
                
                if shouldShowPostThumbnails && thumbnailsOnRight {
                    ThumbnailImageView(postView: postView)
                }
            }
        }
    }
}
