//
//  NewMediaView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-15.
//

import SwiftUI

struct NewMediaView: View {
    @Environment(NavigationLayer.self) var navigation
    
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

    // TODO: update verticalAspectRatioBounds to aspectRatio, include aspectBounding enum (.vertical, .horizontal, .absolute)
    // TODO: loader takes animationEnabled, if not enabled defaults to bare image
    
    /// Creates a new MediaView. This view is simple by default; if no complex behaviors are specified, it will
    /// return a plain image that fits the bounds of its parent frame.
    /// - Parameters:
    ///   - url: url of the media to render
    ///   - verticalAspectRatioBounds: tallest allowable aspect ratio
    ///   - contentMode: content resizing mode
    ///   - cornerRadius: corner radius to apply to the image
    ///   - enableContextMenu: true if the default context menu (save/share/quick look) should appear
    ///   - enableImageViewer: true if tapping the image should open the image viewer
    ///   - enableAnimation: true if animated content should be enabled
    ///   - playImmediately: true if animated media should play without user interaction. If `enableAnimation: false`, this parameter has
    ///     no effect.
    ///   - onTapActions: actions to perform when the image is tapped. If `enableImageViewer: true`, tapping the image will both execute
    ///     the specified actions and open the image viewer
    init(url: URL,
         verticalAspectRatioBounds: CGSize? = nil,
         contentMode: ContentMode = .fit,
         cornerRadius: CGFloat = 0,
         enableContextMenu: Bool = false,
         enableImageViewer: Bool = false,
         enableNsfwBlur: Bool = false,
         // enableAnimation: Bool = false,
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
            .overlay(animatedContentOverlay) // overlay prevents visual hitch when swapping views and preserves frame/cropping
            .overlay(nsfwOverlay)
            .overlay(developerOverlay)
            .onAppear {
                Task {
                    await loader.load()
                }
            }
            .contextMenu {
                if enableContextMenu, let fullSizeUrl = fullSizeUrl {
                    contextMenuContent(url: fullSizeUrl)
                }
            }
            .onTapGesture(perform: tapActions)
        // TEMP BELOW THIS POINT
//            .overlay {
//                if loader.loading != .done {
//                    ProgressView()
//                }
//            }
    }
    
    @ViewBuilder
    var content: some View {
        if #available(iOS 18.0, *) {
            ios18Content
        } else {
            image.onDisappear {
                playing = false
            }
        }
    }
    
    @available(iOS 18.0, *)
    @ViewBuilder
    var ios18Content: some View {
        image
            .onScrollVisibilityChange(threshold: 0.5) { isVisible in
                if isVisible, autoplayMedia {
                    playing = isVisible
                }
                if !isVisible {
                    playing = false
                }
            }
    }
}

extension UIImage {
    /// Returns this image's aspect ratio or the given bounds, whichever is shorter
    func verticallyBoundedAspectRatio(bounds: CGSize) -> CGSize {
        guard size != .zero else { return bounds }

        if size.height / size.width > bounds.height / bounds.width {
            return bounds
        }
        
        return size
    }
}
