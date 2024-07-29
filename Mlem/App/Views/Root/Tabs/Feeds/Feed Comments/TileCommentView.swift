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
    @Environment(\.parentFrameWidth) var parentFrameWidth: CGFloat
    
    let comment: any Comment2Providing
    
    @ScaledMetric(relativeTo: .footnote) var titleHeight: CGFloat = 36 // (2 * .footnote height), including built-in spacing
    @ScaledMetric(relativeTo: .caption) var communityHeight: CGFloat = 16 // .caption height, including built-in spacing
    
    let contentHeightModifier: CGFloat = 33
    // width cannot go below contentHeightModifier so contentWidth is never negative
    var width: CGFloat { max(contentHeightModifier, (parentFrameWidth - (AppConstants.standardSpacing * 3)) / 2) }
    var contentHeight: CGFloat { width - 33 }
    var frameHeight: CGFloat { width + titleHeight + communityHeight + 17 }
    // Padding math
    // Need to satisfy: padding + contentHeightModifier = 17
    //
    // VStack spacing = (2 * AppConstants.standardSpacing) = 20
    // External padding = (2 * AppConstants.standardSpacing) = 20
    // Internal titleSection padding = (2 * AppConstants.halfSpacing) = 10
    //
    // Total padding = 50
    // 50 + contentHeightModifier = 17
    // contentHeightModifier = -33
    
    var body: some View {
        content
            .frame(width: width, height: frameHeight)
            .background(palette.secondaryGroupedBackground)
            .clipShape(.rect(cornerRadius: AppConstants.tilePostCornerRadius))
            .contentShape(.contextMenuPreview, .rect(cornerRadius: AppConstants.tilePostCornerRadius))
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            titleSection
                .frame(height: titleHeight, alignment: .topLeading)
                .padding(AppConstants.halfSpacing)
                .background {
                    RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius)
                        .fill(palette.tertiaryGroupedBackground)
                }
            
            MarkdownText(comment.content, configuration: .default)
                .font(.caption)
                .frame(height: contentHeight, alignment: .top)
                .clipped()

            communityAndInfo
        }
        .padding(AppConstants.standardSpacing)
    }
    
    @ViewBuilder
    var titleSection: some View {
        Text(comment.post.title)
            .lineLimit(2)
            .foregroundStyle(palette.secondary)
            .font(.footnote)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    var replyIcon: Text {
        Text(Image(systemName: Icons.reply))
            .foregroundStyle(palette.accent)
    }
    
    var communityAndInfo: some View {
        HStack(spacing: 6) {
            if let communityName = comment.community_?.name {
                Text(communityName)
                    .lineLimit(1)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(palette.secondary)
            }
            
            Spacer()
            
            score
        }
        .frame(maxWidth: .infinity)
    }
    
    var score: some View {
        Menu {
            ForEach(comment.menuActions(), id: \.id) { action in
                MenuButton(action: action)
            }
        } label: {
            Group {
                Text(Image(systemName: comment.votes_?.iconName ?? Icons.upvoteSquare)) +
                    Text(" \(comment.votes_?.total.abbreviated ?? "0")")
            }
            .lineLimit(1)
            .font(.caption)
            .foregroundStyle(comment.votes_?.iconColor ?? palette.secondary)
            .contentShape(.rect)
        }
        .onTapGesture {}
    }
}
