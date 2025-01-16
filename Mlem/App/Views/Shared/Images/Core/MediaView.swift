//
//  MediaView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-15.
//

import SwiftUI

struct MediaView: View {
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    
    @Setting(\.bypassImageProxyShown) var bypassImageProxyShown
    @Setting(\.autoplayMedia) var autoplayMedia
    @Setting(\.developerMode) var developerMode
    
    @State var loader: MediaLoader
    @State var playing: Bool
    @State var quickLookUrl: URL?
    @State var blurred: Bool
    
    // appearance
    let aspectRatio_: CGSize?
    var aspectRatio: CGSize { aspectRatio_ ?? loader.mediaType.image.validSize(fallback: .init(width: 4, height: 3)) }
    let contentMode: ContentMode
    let cornerRadius: CGFloat
    
    // interaction
    let enableContextMenu: Bool
    let enableImageViewer: Bool
    let enableNsfwBlur: Bool
    let onTapActions: (() -> Void)?
    
    var uiImage: UIImage { loader.mediaType.image }
    var blurValue: CGFloat { blurred ? max(uiImage.size.width, uiImage.size.height) / 12 : 0 }
    var fullSizeUrl: URL? { Mlem.fullSizeUrl(url: loader.url) }
    var contextMenuUrl: URL? { enableContextMenu ? fullSizeUrl : nil }

    // TODO: update verticalAspectRatioBounds to aspectRatio, include aspectBounding enum (.vertical, .horizontal, .absolute)
    
    /// Creates a new MediaView. This view is simple by default; if no complex behaviors are specified, it will
    /// return a plain image that fits the bounds of its parent frame.
    /// - Parameters:
    ///   - url: url of the media to render
    ///   - verticalAspectRatioBounds: tallest allowable aspect ratio
    ///   - contentMode: content resizing mode
    ///   - cornerRadius: corner radius to apply to the image
    ///   - enableContextMenu: true if the default context menu (save/share/quick look) should appear
    ///   - enableImageViewer: true if tapping the image should open the image viewer
    ///   - playImmediately: true if animated media should play without user interaction.
    ///   - onTapActions: actions to perform when the image is tapped. If `enableImageViewer: true`, tapping the image will both execute
    ///     the specified actions and open the image viewer
    init(url: URL,
         verticalAspectRatioBounds: CGSize? = nil,
         contentMode: ContentMode = .fit,
         cornerRadius: CGFloat = 0,
         enableContextMenu: Bool = false,
         enableImageViewer: Bool = false,
         enableNsfwBlur: Bool = false,
         playImmediately: Bool = false,
         onTapActions: (() -> Void)? = nil
    ) {
        self.aspectRatio_ = verticalAspectRatioBounds
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
        
        self.enableContextMenu = enableContextMenu
        self.enableImageViewer = enableImageViewer
        self.enableNsfwBlur = enableNsfwBlur
        self.onTapActions = onTapActions
        
        self._loader = .init(wrappedValue: .init(url: url))
        self._playing = .init(wrappedValue: playImmediately)
        self._blurred = .init(wrappedValue: enableNsfwBlur)
    }
    
    var body: some View {
        content
            // .allowsHitTesting(onTapActions != nil)
            .blur(radius: blurValue, opaque: true)
            .overlay(animationControlOverlay)
            .overlay(nsfwOverlay)
            .overlay(developerOverlay)
            .overlay(errorOverlay)
            .clipShape(.rect(cornerRadius: cornerRadius))
            .withContextMenu(url: contextMenuUrl, menuContent: contextMenuContent)
            // .onTapGesture(perform: tapActions)
            .frame(maxWidth: .infinity)
            .onAppear {
                Task {
                    await loader.load()
                }
            }
            .environment(\.blurred, blurred)
    }
    
    @ViewBuilder
    var content: some View {
        Group {
            if #available(iOS 18.0, *) {
                image
                    .onScrollVisibilityChange(threshold: 0.5) { isVisible in
                        if isVisible, autoplayMedia {
                            playing = isVisible
                        }
                        if !isVisible {
                            playing = false
                        }
                    }
            } else {
                image
                    .onDisappear {
                        playing = false
                    }
            }
        }
    }
}

// MARK: - Modifiers

// Applying these as conditional modifiers rather than modifiers with empty bodies/callbacks prevents
// them from disabling parent view behavior in unexpected ways

private struct MediaViewWithContextMenu<MenuItems: View>: ViewModifier {
    let url: URL?
    let menuContent: (URL) -> MenuItems
    
    func body(content: Content) -> some View {
        if let url {
            content
                .contextMenu {
                    menuContent(url)
                }
        } else {
            content
        }
    }
}

private extension View {
    func withContextMenu(url: URL?, menuContent: @escaping (URL) -> some View) -> some View {
        modifier(MediaViewWithContextMenu(url: url, menuContent: menuContent))
    }
}
