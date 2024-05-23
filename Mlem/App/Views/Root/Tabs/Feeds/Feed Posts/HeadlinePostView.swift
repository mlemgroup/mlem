//
//  HeadlinePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct HeadlinePost: View {
    @AppStorage("post.thumbnailLocation") var thumbnailLocation: ThumbnailLocation = .left
    
    @Environment(Palette.self) var palette: Palette
    
    let post: any Post1Providing
    
    var body: some View {
        content
            .padding(AppConstants.standardSpacing)
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            HStack {
                FullyQualifiedLabelView(entity: post.community_, showAvatar: false, instanceLocation: .bottom)
                
                Spacer()
                
                // TODO: EllipsisMenu
                Image(systemName: "ellipsis")
            }
            
            HStack(alignment: .top, spacing: AppConstants.standardSpacing) {
                if thumbnailLocation == .left {
                    ThumbnailImageView(post: post)
                }
                
                title
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            FullyQualifiedLabelView(entity: post.creator_, showAvatar: false, instanceLocation: .bottom)
        }
    }
    
    var title: Text {
        postTag(active: post.removed, icon: Icons.removeFill, color: .red) +
            postTag(active: post.pinnedInstance, icon: Icons.pinFill, color: palette.administration) +
            postTag(active: post.pinnedCommunity, icon: Icons.pinFill, color: palette.moderation) +
            postTag(active: post.locked, icon: Icons.lockFill, color: palette.orange) +
            Text(post.title)
    }
}
