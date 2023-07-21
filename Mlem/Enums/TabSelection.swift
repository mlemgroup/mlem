//
//  Tab.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-18.
//

import Foundation

enum TabSelection: String, FancyTabBarSelection {
    static func < (lhs: TabSelection, rhs: TabSelection) -> Bool {
        return lhs.index < rhs.index
    }
    
    case feeds, inbox, profile, search, settings
    
    var labelText: String? { return self.rawValue.capitalized }
    
    var index: Int {
        switch self {
        case .feeds: return 1
        case .inbox: return 2
        case .profile: return 3
        case .search: return 4
        case .settings: return 5
        }
    }
}
