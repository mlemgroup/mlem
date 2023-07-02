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
        return self.rawValue.capitalized
    }
    
    case all = "All"
    case local = "Local"
    case subscribed = "Subscribed"
    
//    var label: String { self. }
}
