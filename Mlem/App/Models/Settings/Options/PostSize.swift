//
//  PostSize.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import Icons
import SwiftUI

enum PostSize: String, CaseIterable, Codable {
    case compact, tile, headline, large
    
    /// Convenience because this check comes up a lot
    var tiled: Bool { self == .tile }
    
    var swipeBehavior: SwipeBehavior {
        switch self {
        case .compact, .headline, .large: .standard
        case .tile: .tile
        }
    }

    var label: LocalizedStringResource {
        switch self {
        case .compact: "Compact"
        case .headline: "Headline"
        case .large: "Large"
        case .tile: "Tiled"
        }
    }
    
    var avatarSize: Int? {
        switch self {
        case .compact, .tile:
            return nil
        case .headline, .large:
            return Int(Constants.main.largeAvatarSize * 2)
        }
    }
    
    var imageSize: CGFloat? {
        // TODO: Vary this by device?
        switch self {
        case .compact, .headline: 128
        case .tile: 512
        case .large: nil
        }
    }
    
    var sectionSpacing: CGFloat {
        switch self {
        case .compact: Constants.main.halfSpacing
        default: Constants.main.standardSpacing
        }
    }
    
    var icon: Icon {
        switch self {
        case .compact: .settings.postSizeCompact
        case .tile: .settings.postSizeTiled
        case .headline: .settings.postSizeHeadline
        case .large: .settings.postSizeLarge
        }
    }
    
    var markReadOffset: Int {
        switch self {
        case .compact, .tile: 4
        case .headline: 2
        case .large: 1
        }
    }
}
