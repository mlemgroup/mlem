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
        case .compact: return AppConstants.compactSymbolName
        case .headline: return AppConstants.headlineSymbolName
        case .large: return AppConstants.largeSymbolName
        }
    }
    
    var iconNameFill: String {
        switch self {
        case .compact: return AppConstants.compactSymbolNameFill
        case .headline: return AppConstants.headlineSymbolNameFill
        case .large: return AppConstants.largeSymbolNameFill
        }
    }
}
