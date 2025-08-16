//
//  MediaView+Helpers.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-10.
//

import Foundation
import SwiftUI
import Theming

public extension CoreMediaView {
    // MARK: Types
    enum AspectRatioBounds {
        /// Specify an aspect ratio not taller than .vertical and not wider than the .horizontal
        case bounded(vertical: CGSize?, horizontal: CGSize?)
        /// Specify an exact aspect ratio
        case absolute(CGSize)
        
        public var defaultSize: CGSize {
            switch self {
            case let .bounded(vertical, horizontal):
                vertical ?? horizontal ?? .init(width: 1, height: 1)
            case let .absolute(size):
                size
            }
        }
        
        public var boundsAreSane: Bool {
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
        
        public static var imageDefault: AspectRatioBounds { .bounded(vertical: .init(width: 4, height: 5), horizontal: nil) }
        public static var absoluteSquare: AspectRatioBounds { .absolute(.init(width: 1, height: 1)) }
    }
}
