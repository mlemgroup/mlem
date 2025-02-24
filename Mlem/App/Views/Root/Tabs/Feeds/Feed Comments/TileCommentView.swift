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
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    @Environment(\.parentFrameWidth) var parentFrameWidth: CGFloat
    
    let comment: any Comment
    
    @ScaledMetric(relativeTo: .footnote) var titleHeight: CGFloat = 36 // (2 * .footnote height), including built-in spacing
    @ScaledMetric(relativeTo: .caption) var communityHeight: CGFloat = 16 // .caption height, including built-in spacing
    
    let contentHeightModifier: CGFloat = 33
    // width cannot go below contentHeightModifier so contentWidth is never negative
    var width: CGFloat { max(contentHeightModifier, (parentFrameWidth - (Constants.main.standardSpacing * 3)) / 2) }
    var contentHeight: CGFloat { width - 33 }
    var frameHeight: CGFloat { width + titleHeight + communityHeight + 17 }
    // Padding math
    // Need to satisfy: padding + contentHeightModifier = 17
    //
    // VStack spacing = (2 * Constants.main.standardSpacing) = 20
    // External padding = (2 * Constants.main.standardSpacing) = 20
    // Internal titleSection padding = (2 * Constants.main.halfSpacing) = 10
    //
    // Total padding = 50
    // 50 + contentHeightModifier = 17
    // contentHeightModifier = -33
    
    var body: some View {
        content
            .frame(width: width, height: frameHeight)
            .background(palette.secondaryGroupedBackground)
            .clipShape(.rect(cornerRadius: Constants.main.largeItemCornerRadius))
            .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.largeItemCornerRadius))
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            if let post = comment.post_ {
                titleSection(post: post)
                    .typesettingLanguage(.init(languageCode: .english))
                    .frame(height: titleHeight, alignment: .topLeading)
                    .padding(Constants.main.halfSpacing)
                    .background {
                        RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius)
                            .fill(palette.tertiaryGroupedBackground)
                    }
                    .paletteBorder(cornerRadius: Constants.main.smallItemCornerRadius)
            }
            MarkdownText(comment.content, configuration: .caption)
                .frame(height: contentHeight, alignment: .top)
                .clipped()

            communityAndInfo
        }
        .padding(Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    func titleSection(post: any Post) -> some View {
        Text(post.title)
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
            ForEach(comment.allMenuActions(appState: appState), id: \.id) { action in
                MenuButton(action: action)
            }
        } label: {
            if let comment = comment as? any Comment2Providing {
                TileScoreView(comment)
            } else {
                Image(systemName: Icons.menu)
            }
        }
        .onTapGesture {}
        .popupAnchor()
    }
}
