//
//  Post Sizes.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-29.
//

import Foundation

enum PostSize: String {
    case large, headline, compact
}

extension PostSize: SettingsOptions {
    var label: String {
        rawValue.capitalized
    }
    
    var id: Self { self }
}

extension PostSize: AssociatedIcon {
    var iconName: String {
        switch self {
        case .compact: return Icons.compactPost
        case .headline: return Icons.headlinePost
        case .large: return Icons.largePost
        }
    }
    
    var iconNameFill: String {
        switch self {
        case .compact: return Icons.compactPostFill
        case .headline: return Icons.headlinePostFill
        case .large: return Icons.largePostFill
        }
    }
}
