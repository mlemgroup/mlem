//
//  Tab.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-18.
//

import Foundation

enum TabSelection: String, FancyTabBarSelection {
    case feeds, inbox, profile, search, settings
    
    var labelText: String? { return self.rawValue.capitalized }
}
