//
//  MediaView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-15.
//

import SwiftUI

struct MediaView: View {
    @Environment(NavigationLayer.self) var navigation: NavigationLayer?
    @Environment(\.palette) var palette
    
    @Setting(\.bypassImageProxyShown) var bypassImageProxyShown
    @Setting(\.autoplayMedia) var autoplayMedia
    @Setting(\.developerMode) var developerMode
    
    @State var loader: MediaLoader
    @Binding var controlState: MediaControlState
    @State var quickLookUrl: URL?
    
    let url: URL?
    
    // appearance
    let aspectRatio_: AspectRatioBounds?
    var aspectRatio: AspectRatioBounds { aspectRatio_ ?? .absolute(loader.mediaType?.image.validSize() ?? .init(width: 4, height: 3)) }
    let contentMode: ContentMode
    let cornerRadius: CGFloat
    let fallback: Fallback
    
    // interaction
    let enableContextMenu: Bool
    let enableImageViewer: Bool
    let onTapActions: (() -> Void)?
    
    var fullSizeUrl: URL? { Mlem.fullSizeUrl(url: loader.url) }
    var uiImage: UIImage { loader.mediaType?.image ?? .blank }
    var showErrorOverlay: Bool {
        controlState.enableErrorOverlay &&
            loader.error != nil &&
            navigation != nil
    }

    /// Creates a new MediaView. This view is simple by default; if no complex behaviors are specified, it will
    /// return a plain image that fits the bounds of its parent frame.
    /// - Parameters:
    ///   - url: url of the media to render
    ///   - size: target size of the media
    ///   - controlState: MediaControlState to control this media from a parent view. If not provided, assumes inline rendering mode.
    ///   - aspectRatioBounds: specifies the maximum vertical and horizontal aspect ratio for this image
    ///   - contentMode: content resizing mode
    ///   - cornerRadius: corner radius to apply to the image
    ///   - fallback: fallback to use if image loading fails or URL is not present
    ///   - enableContextMenu: true if the default context menu (save/share/quick look) should appear
    ///   - enableImageViewer: true if tapping the image should open the image viewer
    ///   - onTapActions: actions to perform when the image is tapped. If `enableImageViewer: true`, tapping the image will both execute
    ///     the specified actions and open the image viewer
    ///  - Warning: Changing the following parameters may cause unexpected view identity changes: `enableContextMenu`, `contentMode`
    init(
        url: URL?,
        size: CGSize? = nil,
        controlState: Binding<MediaControlState>? = nil,
        aspectRatioBounds: AspectRatioBounds? = nil,
        contentMode: ContentMode = .fit,
        cornerRadius: CGFloat = 0,
        fallback: Fallback = .image,
        enableContextMenu: Bool = false,
        enableImageViewer: Bool = false,
        onTapActions: (() -> Void)? = nil
    ) {
        self.url = url
        
        self.aspectRatio_ = aspectRatioBounds
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
        self.fallback = fallback
        
        self.enableContextMenu = enableContextMenu
        self.enableImageViewer = enableImageViewer
        self.onTapActions = onTapActions

        self._loader = .init(wrappedValue: .init(url: url, size: size))
        if let controlState {
            self._controlState = controlState
        } else {
            self._controlState = .constant(.init(
                blurred: false,
                animating: false,
                overlays: [.controls, .error]
            )
            )
        }
    }
    
    static func largeImage(url: URL, shouldBlur: Bool, onTapActions: (() -> Void)? = nil) -> MediaView {
        .init(
            url: url,
            controlState: .constant(.init(
                blurred: shouldBlur,
                animating: false,
                overlays: shouldBlur ? [.controls, .nsfw, .error] : [.controls, .error]
            )),
            aspectRatioBounds: .imageDefault,
            cornerRadius: Constants.main.mediumItemCornerRadius,
            enableContextMenu: true,
            enableImageViewer: true,
            onTapActions: onTapActions
        )
    }
    
    var body: some View {
        content
            .dynamicBlur(blurred: loader.mediaType != nil && controlState.blurred)
            .withAnimationControls()
            .overlay(nsfwOverlay)
            .overlay(developerOverlay)
            .overlay(errorOverlay)
            .clipShape(.rect(cornerRadius: cornerRadius))
            .withContextMenu(menuContent: contextMenuContent, isEnabled: enableContextMenu && loader.error == nil)
            .gesture(TapGesture().onEnded(tapActions), isEnabled: (onTapActions != nil) || enableImageViewer)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: url, initial: true) {
                Task {
                    await loader.load(url)
                }
            }
            .onChange(of: loader.mediaType?.isAnimated, initial: true) {
                controlState.animationAvailable = loader.mediaType?.isAnimated ?? false
            }
            .environment(controlState)
    }
    
    @ViewBuilder
    var content: some View {
        Group {
            if #available(iOS 18.0, *) {
                image
                    .onScrollVisibilityChange(threshold: 0.5) { isVisible in
                        if isVisible, autoplayMedia {
                            controlState.animating = true
                        }
                        if !isVisible {
                            controlState.animating = false
                        }
                    }
            } else {
                image
                    .onDisappear {
                        controlState.animating = false
                    }
            }
        }
    }
}

private struct MediaViewWithContextMenu<MenuItems: View>: ViewModifier {
    let menuContent: () -> MenuItems
    let isEnabled: Bool
    
    // This sort of conditional view modifier is generally considered bad form because it can cause unexpected view identity updates.
    // Since `enableContextMenu` is unlikely to be a dynamic value it's acceptable here; nevertheless I have put a warning
    // in the function doc making that behavior explicit. [ Eric 2025-01-16 ]
    func body(content: Content) -> some View {
        if isEnabled {
            content
                .contextMenu {
                    menuContent()
                }
        } else {
            content
        }
    }
}

private extension View {
    /// This view modifier ensures that the context menu is only applied if enabled. If the context menu is instead always applied
    /// but only populated if enabled, it will disable parent context menus (e.g., in `WebsitePreviewView`).
    func withContextMenu(menuContent: @escaping () -> some View, isEnabled: Bool) -> some View {
        modifier(MediaViewWithContextMenu(menuContent: menuContent, isEnabled: isEnabled))
    }
}
