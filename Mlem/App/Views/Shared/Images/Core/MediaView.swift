//
//  MediaView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-15.
//

import SwiftUI

struct MediaView: View {
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.palette) var palette
    
    @Setting(\.bypassImageProxyShown) var bypassImageProxyShown
    @Setting(\.autoplayMedia) var autoplayMedia
    @Setting(\.developerMode) var developerMode
    
    @State var loader: MediaLoader
    @State var controlState: MediaControlState
    @State var playing: Bool
    @State var quickLookUrl: URL?
    @State var blurred: Bool
    
    // appearance
    let aspectRatio_: AspectRatioBounds?
    var aspectRatio: AspectRatioBounds { aspectRatio_ ?? .absolute(loader.mediaType.image.validSize(fallback: .init(width: 4, height: 3))) }
    let contentMode: ContentMode
    let cornerRadius: CGFloat
    
    // interaction
    let enableContextMenu: Bool
    let enableImageViewer: Bool
    let enableNsfwBlur: Bool
    let onTapActions: (() -> Void)?
    
    var uiImage: UIImage { loader.mediaType.image }
    var fullSizeUrl: URL? { Mlem.fullSizeUrl(url: loader.url) }

    /// Creates a new MediaView. This view is simple by default; if no complex behaviors are specified, it will
    /// return a plain image that fits the bounds of its parent frame.
    /// - Parameters:
    ///   - url: url of the media to render
    ///   - controlState: MediaControlState to control this media from a parent view. If not provided, assumes inline rendering mode.
    ///   - verticalAspectRatioBounds: tallest allowable aspect ratio
    ///   - horizontalAspectRatioBounds: widest allowable aspect ratio
    ///   - contentMode: content resizing mode
    ///   - cornerRadius: corner radius to apply to the image
    ///   - enableContextMenu: true if the default context menu (save/share/quick look) should appear
    ///   - enableImageViewer: true if tapping the image should open the image viewer
    ///   - playImmediately: true if animated media should play without user interaction
    ///   - onTapActions: actions to perform when the image is tapped. If `enableImageViewer: true`, tapping the image will both execute
    ///     the specified actions and open the image viewer
    ///  - Warning: Changing the following parameters may cause unexpected view identity changes: `enableContextMenu`, `contentMode`
    init(url: URL,
         controlState: MediaControlState? = nil,
         aspectRatioBounds: AspectRatioBounds? = nil,
         contentMode: ContentMode = .fit,
         cornerRadius: CGFloat = 0,
         enableContextMenu: Bool = false,
         enableImageViewer: Bool = false,
         enableNsfwBlur: Bool = false,
         playImmediately: Bool = false,
         onTapActions: (() -> Void)? = nil
    ) {
        self.aspectRatio_ = aspectRatioBounds
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
        
        self.enableContextMenu = enableContextMenu
        self.enableImageViewer = enableImageViewer
        self.enableNsfwBlur = enableNsfwBlur
        self.onTapActions = onTapActions
        
        self._loader = .init(wrappedValue: .init(url: url))
        self._playing = .init(wrappedValue: playImmediately)
        self._blurred = .init(wrappedValue: enableNsfwBlur)
        self._controlState = .init(wrappedValue: controlState ?? .init(
            animating: false,
            embedControls: true
        ))
    }
    
    var body: some View {
        content
            .dynamicBlur(blurred: blurred)
            .overlay(animationControlOverlay)
            .overlay(nsfwOverlay)
            .overlay(developerOverlay)
            .overlay(errorOverlay)
            .clipShape(.rect(cornerRadius: cornerRadius))
            .withContextMenu(menuContent: contextMenuContent, isEnabled: enableContextMenu && loader.error == nil)
            .gesture(TapGesture().onEnded(tapActions), isEnabled: (onTapActions != nil) || enableImageViewer)
            .frame(maxWidth: .infinity)
            .onChange(of: blurred) {
                if !blurred { playing = true }
            }
            .onAppear {
                Task {
                    await loader.load()
                }
            }
            .onChange(of: loader.mediaType.isAnimated, initial: true) {
                controlState.animationAvailable = loader.mediaType.isAnimated
            }
            .environment(controlState)
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

enum AspectRatioBounds {
    /// Specify an aspect ratio not taller than .vertical and not wider than the .horizontal
    case bounded(vertical: CGSize?, horizontal: CGSize?)
    /// Specify an exact aspect ratio
    case absolute(CGSize)
    
    var defaultSize: CGSize {
        switch self {
        case let .bounded(vertical, horizontal):
            vertical ?? horizontal ?? .init(width: 1, height: 1)
        case let .absolute(size):
            size
        }
    }
    
    var boundsAreSane: Bool {
        switch self {
        case let .bounded(vertical, horizontal):
            if let vertical, let horizontal {
                // if both horizontal and vertical bound defined, ensure vertical bound taller than horizontal
                return vertical.aspectRatio > horizontal.aspectRatio
            } else {
                return true
            }
        case .absolute:
            return true
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
