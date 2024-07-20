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
    
    @ScaledMetric(relativeTo: .footnote) var titleHeight: CGFloat = 36 // (2 * .footnote height), including built-in spacing
    @ScaledMetric(relativeTo: .caption) var communityHeight: CGFloat = 16 // .caption height, including built-in spacing
    var dimension: CGFloat { (UIScreen.main.bounds.width - (AppConstants.standardSpacing * 3)) / 2 }
    var frameHeight: CGFloat {
        dimension + // picture
            titleHeight + (AppConstants.standardSpacing * 2) - 3 + // title + padding
            communityHeight + (AppConstants.standardSpacing) // community + padding
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
                .frame(height: titleHeight, alignment: .topLeading)
                .padding(AppConstants.standardSpacing)
                .padding(.bottom, -3)
            
            Divider()
            
            Markdown(comment.content, configuration: .default)
                .font(.caption)
                .padding(AppConstants.standardSpacing)
                .frame(height: dimension, alignment: .top)
                .clipped()

            communityAndInfo
                .padding(.horizontal, AppConstants.standardSpacing)
                .padding(.vertical, AppConstants.halfSpacing)
        }
    }
    
    @ViewBuilder
    var titleSection: some View {
        (replyIcon + Text("  \(comment.post.title)"))
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
        //        Menu {
        //            ForEach(post.menuActions(), id: \.id) { action in
        //                MenuButton(action: action)
        //            }
        //        } label: {
        Group {
            Text(Image(systemName: comment.votes_?.iconName ?? Icons.upvoteSquare)) +
                Text(" \(comment.votes_?.total.abbreviated ?? "0")")
        }
        .lineLimit(1)
        .font(.caption)
        .foregroundStyle(comment.votes_?.iconColor ?? palette.secondary)
        .contentShape(.rect)
        //        }
        //        .onTapGesture {}
    }
}
