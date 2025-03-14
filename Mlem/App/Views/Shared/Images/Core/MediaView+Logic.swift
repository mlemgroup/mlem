//
//  MediaView+Helpers.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-10.
//

import Foundation
import SwiftUICore
import Theming

extension MediaView {
    // MARK: Types
    
    enum Overlay {
        case controls, nsfw, error
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
        
        static var imageDefault: AspectRatioBounds { .bounded(vertical: .init(width: 4, height: 5), horizontal: nil) }
        static var absoluteSquare: AspectRatioBounds { .absolute(.init(width: 1, height: 1)) }
    }

    enum FallbackStyle {
        case standard, avatar
    }
    
    /// Enumeration of placeholder images to use if image loading fails
    enum Fallback {
        case personAvatar, communityAvatar, instanceAvatar, favicon, image, movie, text, link, titleOnly, proxyFailure
        
        var icon: String {
            switch self {
            case .personAvatar: Icons.personCircleFill
            case .communityAvatar: Icons.communityCircleFill
            case .instanceAvatar: Icons.instanceCircleFill
            case .favicon: Icons.browser
            case .image: Icons.missing
            case .movie: Icons.movie
            case .text: Icons.textPost
            case .link: Icons.websiteIcon
            case .titleOnly: Icons.titleOnlyPost
            case .proxyFailure: Icons.proxy
            }
        }
        
        /// How much of the parent view this fallback should occupy
        var scaleFactor: CGFloat {
            switch self {
            case .personAvatar, .communityAvatar, .instanceAvatar, .favicon: 1.0
            case .image, .proxyFailure: 0.375
            case .link, .text: 0.4
            case .titleOnly: 0.45
            case .movie: 0.6
            }
        }
        
        /// Background color for the fallback view.
        /// - Note: this has no effect if `fallbackStyle` is `.avatar`
        var background: ThemedColor {
            switch self {
            case .favicon: .clear
            default: .themedThumbnailBackground
            }
        }
        
        var fallbackStyle: FallbackStyle {
            switch self {
            case .personAvatar, .communityAvatar, .instanceAvatar: .avatar
            default: .standard
            }
        }
    }
    
    // MARK: Functions
    
    func tapActions() {
        if let onTapActions {
            onTapActions()
        }
        if enableImageViewer, let navigation, let viewerUrl = fullSizeUrl ?? loader.url {
            navigation.showImageViewer(url: viewerUrl)
        }
    }
}
