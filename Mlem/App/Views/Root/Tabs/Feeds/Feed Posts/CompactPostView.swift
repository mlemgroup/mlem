//
//  CompactPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct CompactPost: View {
    @AppStorage("post.thumbnailLocation") var thumbnailLocation: ThumbnailLocation = .left
    
    @Environment(\.communityContext) var communityContext: (any Community3Providing)?
    
    let post: any Post1Providing
    
    var body: some View {
        content
            .padding(AppConstants.standardSpacing)
    }
    
    var content: some View {
        HStack(alignment: .top, spacing: AppConstants.standardSpacing) {
            if thumbnailLocation == .left {
                ThumbnailImageView(post: post)
            }
            
            VStack(alignment: .leading, spacing: AppConstants.compactSpacing) {
                HStack {
                    if communityContext != nil {
                        FullyQualifiedLabelView(entity: post.creator_, showAvatar: false, instanceLocation: .trailing)
                    } else {
                        FullyQualifiedLabelView(entity: post.community_, showAvatar: false, instanceLocation: .trailing)
                    }
                    Spacer()
                    // TODO: EllipsisMenu
                    Image(systemName: "ellipsis")
                }
                
                Text(post.title)
                    .font(.subheadline)
                
                // TODO: info stack
            }
            
            if thumbnailLocation == .right {
                ThumbnailImageView(post: post)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
