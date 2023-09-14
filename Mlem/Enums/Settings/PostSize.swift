//
//  Post Sizes.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-29.
//

import Foundation

enum PostSize: String {
    case compact, headline, large
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
        case .compact: return Icons.compactSymbolName
        case .headline: return Icons.headlineSymbolName
        case .large: return Icons.largeSymbolName
        }
    }
    
    var iconNameFill: String {
        switch self {
        case .compact: return Icons.compactSymbolNameFill
        case .headline: return Icons.headlineSymbolNameFill
        case .large: return Icons.largeSymbolNameFill
        }
    }
}
