//
//  MediaView+Helpers.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-10.
//

import Foundation

extension MediaView {
    
    // MARK: Types
    
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

    /// Enumeration of placeholder images to use if image loading fails
    enum Fallback {
        case person, community, instance, favicon, image, movie, text, link, titleOnly
        
        var icon: String {
            switch self {
            case .person: Icons.personCircleFill
            case .community: Icons.communityCircleFill
            case .instance: Icons.instanceCircleFill
            case .favicon: Icons.browser
            case .image: Icons.missing
            case .movie: "film"
            case .text: Icons.textPost
            case .link: Icons.websiteIcon
            case .titleOnly: Icons.titleOnlyPost
            }
        }
    }
    
    // MARK: Functions
    
    func tapActions() {
        if let onTapActions {
            onTapActions()
        }
        if enableImageViewer, let viewerUrl = fullSizeUrl ?? loader.url {
            navigation.showImageViewer(url: viewerUrl)
        }
    }
}
