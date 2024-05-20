//
//  CompactPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct CompactPost: View {
    let post: any Post1Providing
    
    var body: some View {
        // TODO: this PR thumbnail location
        HStack(alignment: .top, spacing: AppConstants.standardSpacing) {
            // TODO: this PR move this to ThumbnailImageView
            Image(systemName: "photo")
                .frame(width: AppConstants.thumbnailSize, height: AppConstants.thumbnailSize)
                .background(Color.gray)
            
            VStack(alignment: .leading, spacing: AppConstants.compactSpacing) {
                HStack {
                    UserLabelView(person: post.creator_)
                    Spacer()
                    // TODO: this PR EllipsisMenu
                    Image(systemName: "ellipsis")
                }
                
                Text(post.title)
                    .font(.subheadline)
                
                // TODO: this PR info stack
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppConstants.standardSpacing)
    }
}
