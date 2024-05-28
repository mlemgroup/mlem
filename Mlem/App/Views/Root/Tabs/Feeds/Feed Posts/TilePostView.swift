//
//  TilePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-27.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct TilePost: View {
    @Environment(Palette.self) var palette: Palette
    
    let post: any Post1Providing

    // magic number alert! ((footnote size + leading) / 2) + (vertical padding on capsules) = (18 / 2) + (2) = 11
    @ScaledMetric(relativeTo: .footnote) var cornerRadius: CGFloat = 11
    var dimension: CGFloat { UIScreen.main.bounds.width / 2 }
    
    var body: some View {
        content
            .frame(width: dimension, height: dimension)
    }
    
    var content: some View {
        HStack(alignment: .top, spacing: 0) {
            Divider()
  
            baseImage
                .overlay {
                    VStack(alignment: .leading, spacing: AppConstants.compactSpacing) {
                        Text(post.title)
                            .lineLimit(2)
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .padding(2)
                            .padding(.horizontal, 4)
                            .background {
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .fill(.regularMaterial)
                                    .overlay(RoundedRectangle(cornerRadius: cornerRadius).fill(palette.background.opacity(0.25)))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        PostLinkHostView(host: post.linkHost)
                            .font(.caption)
                            .padding(2)
                            .padding(.horizontal, 4)
                            .background {
                                Capsule()
                                    .fill(.regularMaterial)
                                    .overlay(Capsule().fill(palette.background.opacity(0.25)))
                            }
                        
                        Spacer()
                        
                        info
                            .lineLimit(1)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(2)
                            .padding(.horizontal, 4)
                            .background {
                                Capsule()
                                    .fill(.regularMaterial)
                                    .overlay(Capsule().fill(palette.background.opacity(0.25)))
                            }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(AppConstants.compactSpacing)
                }
            
            Divider()
        }
    }
    
    var baseImage: some View {
        // TODO: pending image handling get the actual image--same logic as needed for ThumbnailImageView, can extract to helper
        Image(systemName: post.placeholderImageName)
            .resizable()
            .scaledToFit()
            .foregroundStyle(palette.secondary)
            .frame(width: AppConstants.thumbnailSize, height: AppConstants.thumbnailSize)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(.indigo)
    }
    
    // TODO: this should be fleshed out to use live values--requires some middleware work to make those conveniently available. This is just a quick-and-dirty way to mock up how it would look.
    var info: Text {
        Text(Image(systemName: Icons.upvoteSquare)) +
            Text("34") +
            Text("  ") +
            Text(Image(systemName: Icons.save)) +
            Text("  ") +
            Text(Image(systemName: Icons.replies)) +
            Text("12")
    }
}
