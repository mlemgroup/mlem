//
//  TileCommentView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-07-19.
//

import Foundation
import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct TileCommentView: View {
    @Environment(Palette.self) var palette
    
    let comment: any Comment2Providing
    
    @ScaledMetric(relativeTo: .footnote) var minTitleHeight: CGFloat = 36 // (2 * .footnote height), including built-in spacing
    var dimension: CGFloat { (UIScreen.main.bounds.width - (AppConstants.standardSpacing * 3)) / 2 }
    var frameHeight: CGFloat {
        dimension + // picture
            minTitleHeight + // title section
            (AppConstants.standardSpacing * 3) + // vertical spacing--not actually sure why it has to be 3 instead of 2, but it does
            2 // spacing between title and community
    }
    
    var body: some View {
        content
            .frame(width: dimension, height: frameHeight)
            .background(palette.secondaryGroupedBackground)
            .clipShape(.rect(cornerRadius: AppConstants.tilePostCornerRadius))
            .contentShape(.contextMenuPreview, .rect(cornerRadius: AppConstants.tilePostCornerRadius))
            .shadow(color: palette.primary.opacity(0.1), radius: 3)
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleSection
                .padding([.top, .horizontal], AppConstants.standardSpacing)
                .padding(.bottom, 7)
            
            Divider()
            
            Markdown(comment.content, configuration: .default)
                .font(.caption)
                .padding(AppConstants.standardSpacing)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    var titleSection: some View {
        (replyIcon + Text("  \(comment.post.title)"))
            .lineLimit(2)
            .foregroundStyle(palette.secondary)
            .font(.footnote)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, minHeight: minTitleHeight, alignment: .topLeading)
    }
    
    var replyIcon: Text {
        Text(Image(systemName: Icons.reply))
            .foregroundStyle(palette.accent)
    }
}
