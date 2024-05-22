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
    let showUsername: Bool
    
    var body: some View {
        content
            .padding(AppConstants.standardSpacing)
    }
    
    var content: some View {
        // TODO: this PR thumbnail location
        HStack(alignment: .top, spacing: AppConstants.standardSpacing) {
            ThumbnailImageView(post: post)
            
            VStack(alignment: .leading, spacing: AppConstants.compactSpacing) {
                HStack {
                    if showUsername {
                        FullyQualifiedLabelView(entity: post.creator_, showAvatar: false, instanceLocation: .trailing)
                    } else {
                        FullyQualifiedLabelView(entity: post.community_, showAvatar: false, instanceLocation: .trailing)
                    }
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
    }
}
