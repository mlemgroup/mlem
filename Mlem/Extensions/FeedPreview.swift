//
//  FeedPreview.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-06.
//

import Foundation
import SwiftUI

struct FeedPreview: ViewModifier {
    let imageOnly: Bool
    
    func body(content: Content) -> some View {
        // let gradientSize: CGFloat = AppConstants.postAndCommentSpacing // for easy modification
        let gradientSize: CGFloat = 20
        
        content
            .overlay {
                GeometryReader { geo in
                    if geo.size.height > AppConstants.maxFeedPostHeight {
                        Rectangle()
                            .fill(
                                LinearGradient(colors: [.clear, .secondarySystemBackground], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: gradientSize)
                            .offset(y: AppConstants.maxFeedPostHeight - gradientSize)
                    }
                }
            }
            .frame(maxHeight: AppConstants.maxFeedPostHeight, alignment: .top)
            .clipped()
            .cornerRadius(AppConstants.largeItemCornerRadius)
            .padding(imageOnly ? 0 : 8)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(AppConstants.largeItemCornerRadius)
    }
}

extension View {
    @ViewBuilder func feedPreview(imageOnly: Bool) -> some View {
        modifier(FeedPreview(imageOnly: imageOnly))
    }
}
