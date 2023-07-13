//
//  FeedType.swift
//  Mlem
//
//  Created by Jonathan de Jong on 12.06.2023.
//

import Foundation

enum FeedType: String, Encodable, SettingsOptions {
    
    var id: Self { self }

    var label: String {
        switch self {
        case .all: return "All Known"
        case .local: return self.rawValue
        case .subscribed: return self.rawValue
        }
    }
    
    case all = "All"
    case local = "Local"
    case subscribed = "Subscribed"
}
