//
//  PostEditorWebsitePreviewView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-07.
//

import MlemMiddleware
import SwiftUI

struct PostEditorWebsitePreviewView: View {
    @Setting(\.post_webPreview_showIcon) var showFavicons
    @Setting(\.behavior_muteVideos) var muteVideos
    
    @Binding var link: PostLink
    let removeCallback: () -> Void
    let shouldBlur: Bool
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.themedTertiaryGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: Constants.main.mediumItemCornerRadius))
            .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.mediumItemCornerRadius))
            .paletteBorder(cornerRadius: Constants.main.mediumItemCornerRadius)
            .contentShape(.rect)
    }
    
    @ViewBuilder
    var content: some View {
        if let thumbnailUrl = link.effectiveThumbnail {
            VStack(alignment: .leading, spacing: 0) {
                MediaView(
                    url: thumbnailUrl,
                    controlState: .constant(.init(
                        blurred: shouldBlur,
                        animating: false,
                        muted: muteVideos
                    )),
                    aspectRatioBounds: .bounded(vertical: .init(width: 1, height: 1), horizontal: nil),
                    contentMode: .fill,
                    overlays: shouldBlur ? [.controls, .nsfw, .error] : [.controls, .error]
                )
                .overlay(alignment: .bottomLeading) {
                    LinkHostView(link: link, withCapsule: true)
                        .padding(Constants.main.halfSpacing)
                }
                .overlay(alignment: .topTrailing) {
                    removeButton
                        .padding(10)
                }
                titleView
            }
        } else {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    LinkHostView(link: link, withCapsule: false)
                        .padding([.horizontal, .top], Constants.main.standardSpacing)
                    titleView
                }
                Spacer()
                removeButton
                    .padding(.trailing, 10)
            }
        }
    }

    @ViewBuilder
    var titleView: some View {
        Text(link.label)
            .font(.subheadline)
            .fontWeight(.semibold)
            .padding(Constants.main.standardSpacing)
            .foregroundStyle(.themedPrimary)
    }

    @ViewBuilder
    var removeButton: some View {
        Button(
            "Remove",
            systemImage: Icons.closeCircleFill,
            action: removeCallback
        )
        .buttonStyle(.plain)
        .font(.title)
        .fontWeight(.semibold)
        .imageScale(.large)
        .labelStyle(.iconOnly)
        .symbolRenderingMode(.hierarchical)
    }
}
