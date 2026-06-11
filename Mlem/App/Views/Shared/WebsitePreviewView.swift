//
//  WebsitePreviewView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-16.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct WebsitePreviewView: View {
    @Environment(\.openURL) private var openURL
    @Environment(MediaTracker.self) var mediaTracker
    
    @Setting(\.post_webPreview_showIcon) var showFavicons
    @Setting(\.behavior_muteVideos) var muteVideos

    let shouldBlur: Bool
    let nsfw: Bool
    
    let link: PostLink
    var onTapActions: (() -> Void)?
    
    init(link: PostLink, shouldBlur: Bool, nsfw: Bool, onTapActions: (() -> Void)? = nil) {
        self.link = link
        self.onTapActions = onTapActions
        self.shouldBlur = shouldBlur
        self.nsfw = nsfw
    }
    
    var body: some View {
        content
            .contentShape(.rect)
            .onTapGesture {
                if let onTapActions {
                    onTapActions()
                }
                openURL(link.content)
            }
            .contextMenu {
                Button("Open", icon: .general.browser) {
                    openURL(link.content)
                }
                Button("Copy", icon: .general.copy) {
                    let pasteboard = UIPasteboard.general
                    pasteboard.url = link.content
                }
                ShareLink(item: link.content)
            } preview: { WebView(url: link.content) }
    }
    
    var content: some View {
        complex
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.themedTertiaryGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: Constants.main.mediumItemCornerRadius))
            .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.mediumItemCornerRadius))
            .paletteBorder(cornerRadius: Constants.main.mediumItemCornerRadius)
            .contentShape(.rect)
    }
    
    var complex: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let thumbnailUrl = link.effectiveThumbnail {
                MediaView(
                    controlState: mediaTracker.controlState(for: thumbnailUrl) {
                        .init(
                            url: thumbnailUrl,
                            blurred: shouldBlur,
                            animating: false,
                            muted: muteVideos
                        )
                    },
                    aspectRatioBounds: .bounded(vertical: .init(width: 1, height: 1), horizontal: nil),
                    contentMode: .fill,
                    overlays: shouldBlur || nsfw ? [.controls, .nsfw, .error] : [.controls, .error]
                )
                .overlay(alignment: .bottomLeading) {
                    LinkHostView(link: link, withCapsule: true)
                        .padding(Constants.main.halfSpacing)
                }
            } else {
                LinkHostView(link: link, withCapsule: false)
                    .padding([.horizontal, .top], Constants.main.standardSpacing)
            }
            
            Text(link.label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(Constants.main.standardSpacing)
                .foregroundStyle(.themedPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
