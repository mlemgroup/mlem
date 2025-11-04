//
//  PostEditorWebsitePreviewView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-07.
//

import MlemMiddleware
import SwiftUI
import Theming

struct PostEditorWebsitePreviewView: View {
    @Environment(\.palette) var palette

    @Setting(\.post_webPreview_showIcon) var showFavicons
    @Setting(\.behavior_muteVideos) var muteVideos
    
    @Binding var link: PostLink
    @Binding var imageManager: ImageUploadManager

    @State var isEditing: Bool = false

    let primaryApi: ApiClient
    let removeCallback: () -> Void
    let shouldBlur: Bool
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.themedSecondaryGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: Constants.main.mediumItemCornerRadius))
            .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.mediumItemCornerRadius))
            .paletteBorder(cornerRadius: Constants.main.mediumItemCornerRadius)
            .contentShape(.rect)
    }

    @ViewBuilder
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isEditing {
                LinkEditorView(url: link.content, api: primaryApi) { link in
                    self.link = link
                    withAnimation(.easeOut(duration: 0.2)) {
                        isEditing = false
                    }
                }
            } else if let thumbnailUrl = imageManager.image?.url ?? link.effectiveThumbnail {
                imageView(thumbnailUrl)
                footerView(withLinkHost: false, withRemoveButton: false)
            } else if primaryApi.supports(.customPostThumbnail, defaultValue: false) {
                imagePlaceholderView
                footerView(withLinkHost: true, withRemoveButton: false)
            } else {
                footerView(withLinkHost: true, withRemoveButton: true)
            }
        }
    }

    @ViewBuilder
    func footerView(withLinkHost showLinkHost: Bool, withRemoveButton showRemoveButton: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                if showLinkHost {
                    LinkHostView(link: link, withCapsule: false)
                        .padding([.horizontal, .top], Constants.main.standardSpacing)
                }
                titleView
            }
            Spacer()
            HStack {
                editButton
                if showRemoveButton {
                    removeButton
                }
            }
            .foregroundStyle(.secondary, .themedTertiaryGroupedBackground)
            .padding(.trailing, 10)
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
    func imageView(_ thumbnailUrl: URL) -> some View {
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
        .overlay(alignment: .topLeading) {
            if primaryApi.supports(.customPostThumbnail, defaultValue: false) {
                thumbnailUploadButton
                    .padding(10)
            }
        }
        .overlay(alignment: .topTrailing) {
            removeButton
                .padding(10)
                .foregroundStyle(.secondary, .thinMaterial)
        }
    }

    @ViewBuilder
    var imagePlaceholderView: some View {
        ZStack {
            ThemedColor.themedAccent.resolve(with: palette).opacity(0.2)
                .frame(maxWidth: .infinity)
                .aspectRatio(5 / 3, contentMode: .fit)
            VStack {
                Image(icon: .general.photoLibary)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.themedAccent.opacity(0.2))
                    .frame(width: 80)
                Text("No image")
                    .foregroundStyle(.themedAccent.opacity(0.5))
                    .fontWeight(.semibold)
                ImageUploadMenu(imageManager: imageManager, imageUploadApi: primaryApi) {
                    Text("Upload")
                }
                .font(.footnote)
                .buttonStyle(.borderedProminent)
                .padding(.top, 10)
            }
        }
        .overlay(alignment: .topTrailing) {
            removeButton
                .padding(10)
                .foregroundStyle(.themedAccent, .themedAccent.opacity(0.2))
        }
    }

    @ViewBuilder
    var removeButton: some View {
        Button(
            "Remove",
            icon: .general.close
        ) {
            Task {
                do {
                    try await imageManager.image?.delete()
                    removeCallback()
                } catch {
                    handleError(error)
                }
            }
        }
        .buttonStyle(OverlayButtonStyle())
    }

    @ViewBuilder
    var editButton: some View {
        Button("Edit link", icon: .general.link) {
            withAnimation(.easeOut(duration: 0.2)) {
                isEditing = true
            }
        }
        .buttonStyle(OverlayButtonStyle())
    }

    @ViewBuilder
    var thumbnailUploadButton: some View {
        if imageManager.image != nil {
            Button("Custom Thumbnail", icon: .general.close) {
                Task {
                    do {
                        try await imageManager.delete()
                    } catch {
                        handleError(error)
                    }
                }
            }
            .fontWeight(.semibold)
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .background(.thinMaterial, in: .capsule)
            .foregroundStyle(.secondary)
            .padding(5)
        } else {
            ImageUploadMenu(imageManager: imageManager, imageUploadApi: primaryApi) {
                Label("Change Thumbnail", icon: .general.chooseImage)
            }
            .buttonStyle(OverlayButtonStyle())
            .foregroundStyle(.secondary, .thinMaterial)
        }
    }
}

private struct OverlayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title)
            .fontWeight(.semibold)
            .imageScale(.large)
            .labelStyle(.iconOnly)
            .symbolVariant(.circle.fill)
            .symbolRenderingMode(.palette)
    }
}
