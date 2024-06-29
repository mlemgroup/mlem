//
//  FeedIconView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-27.
//

import Foundation
import SwiftUI

struct FeedIconView: View {
    @Environment(Palette.self) var palette
    
    let feedDescription: FeedDescription
    let size: CGFloat
    let scaledSize: CGFloat
    
    init(feedDescription: FeedDescription, size: CGFloat) {
        self.feedDescription = feedDescription
        self.size = size
        self.scaledSize = size * feedDescription.iconScaleFactor
    }
    
    var body: some View {
        Circle()
            .fill(feedDescription.color ?? palette.accent)
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: feedDescription.iconNameFill)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .frame(width: scaledSize, height: scaledSize)
            }
    }
}
